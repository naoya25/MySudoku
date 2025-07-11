import SwiftUI

struct PuzzleCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var isGenerating = false
  @State private var generationProgress = 0.0
  @State private var currentGenerationCount = 0
  @State private var totalGenerationCount = 0
  @State private var generatedPuzzles: [(puzzle: String, solution: String)] = []
  @State private var showingResults = false

  var body: some View {
    VStack(spacing: 20) {
      Text("ナンプレ問題作成")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)

      if isGenerating {
        VStack(spacing: 16) {
          Text("生成中: \(currentGenerationCount)/\(totalGenerationCount)")
            .font(.headline)
            .foregroundColor(.secondary)

          ProgressView(value: generationProgress)
            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            .scaleEffect(x: 1, y: 2, anchor: .center)
            .padding(.horizontal, 40)

          Text("\(Int(generationProgress * 100))%")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 40)
      }

      VStack(spacing: 16) {
        Button(action: {
          generatePuzzles(count: 1)
        }) {
          Text("1問生成")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isGenerating ? Color.gray : Color.blue)
            .cornerRadius(12)
        }
        .disabled(isGenerating)

        Button(action: {
          generatePuzzles(count: 10)
        }) {
          Text("10問生成")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isGenerating ? Color.gray : Color.green)
            .cornerRadius(12)
        }
        .disabled(isGenerating)

        Button(action: {
          generatePuzzles(count: 100)
        }) {
          Text("100問生成")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isGenerating ? Color.gray : Color.orange)
            .cornerRadius(12)
        }
        .disabled(isGenerating)

      }
      .padding(.horizontal, 40)

      if showingResults && !generatedPuzzles.isEmpty {
        VStack(spacing: 12) {
          Text("生成完了: \(generatedPuzzles.count)問")
            .font(.headline)
            .fontWeight(.bold)

          ScrollView {
            LazyVStack(spacing: 8) {
              ForEach(Array(generatedPuzzles.enumerated()), id: \.offset) { index, puzzle in
                let difficulty = DifficultyCalculatorService.shared
                  .calculateDifficultyWithTechniques(
                    puzzle: puzzle.puzzle,
                    solution: puzzle.solution
                  )
                let emptyCount = puzzle.puzzle.filter { $0 == "0" }.count

                HStack {
                  VStack(alignment: .leading, spacing: 4) {
                    Text("問題 \(index + 1)")
                      .font(.caption)
                      .foregroundColor(.secondary)

                    HStack {
                      Text("難易度: \(difficulty.difficulty)")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(getDifficultyColor(difficulty.rank))
                        .cornerRadius(4)

                      Text("空欄: \(emptyCount)マス")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }

                    Text(difficulty.rank.name)
                      .font(.caption2)
                      .fontWeight(.medium)
                      .foregroundColor(getDifficultyTextColor(difficulty.rank))
                  }

                  Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: 1)
              }
            }
          }
          .frame(maxHeight: 200)

          Button(action: {
            showingResults = false
            generatedPuzzles.removeAll()
          }) {
            Text("結果をクリア")
              .font(.caption)
              .foregroundColor(.red)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(Color.red.opacity(0.1))
              .cornerRadius(8)
          }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 40)
      }

      Spacer()
    }
    .navigationTitle("問題作成")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func generatePuzzles(count: Int) {
    isGenerating = true
    showingResults = false
    generationProgress = 0.0
    currentGenerationCount = 0
    totalGenerationCount = count
    generatedPuzzles.removeAll()

    Task {
      await generatePuzzlesAsync(count: count)
    }
  }

  private func generatePuzzlesAsync(count: Int) async {
    for i in 1...count {
      let result = await Task.detached {
        return PuzzleGeneratorService.shared.generatePuzzle()
      }.value

      await MainActor.run {
        generatedPuzzles.append(result)
        currentGenerationCount = i
        generationProgress = Double(i) / Double(count)
      }
    }

    await MainActor.run {
      isGenerating = false
      showingResults = true
      print("=== 生成完了 ===")
      print("総問題数: \(generatedPuzzles.count)")

      // 難易度別の統計を表示
      let difficulties = generatedPuzzles.map { puzzle in
        DifficultyCalculatorService.shared.calculateDifficultyWithTechniques(
          puzzle: puzzle.puzzle,
          solution: puzzle.solution
        )
      }

      let rankCounts = Dictionary(grouping: difficulties, by: { $0.rank })
        .mapValues { $0.count }

      print("難易度別統計:")
      for rank in DifficultyRank.allCases {
        let count = rankCounts[rank] ?? 0
        print("  \(rank.name): \(count)問")
      }

      // Supabaseに保存
      Task {
        await savePuzzlesToSupabase(puzzles: generatedPuzzles, difficulties: difficulties)
      }
    }
  }

  private func savePuzzlesToSupabase(
    puzzles: [(puzzle: String, solution: String)], difficulties: [DifficultyResult]
  ) async {
    print("=== Supabaseに保存中 ===")

    let puzzleData = zip(puzzles, difficulties).map { (puzzle, difficulty) in
      (puzzle: puzzle.puzzle, solution: puzzle.solution, difficulty: difficulty.difficulty)
    }

    do {
      try await SupabaseService.shared.savePuzzles(puzzleData)
      print("=== 保存完了 ===")
    } catch {
      print("保存エラー: \(error.localizedDescription)")
    }
  }

  private func getDifficultyColor(_ rank: DifficultyRank) -> Color {
    switch rank {
    case .beginner:
      return Color.green.opacity(0.3)
    case .intermediate:
      return Color.blue.opacity(0.3)
    case .advanced:
      return Color.orange.opacity(0.3)
    case .expert:
      return Color.red.opacity(0.3)
    case .master:
      return Color.purple.opacity(0.3)
    }
  }

  private func getDifficultyTextColor(_ rank: DifficultyRank) -> Color {
    switch rank {
    case .beginner:
      return Color.green
    case .intermediate:
      return Color.blue
    case .advanced:
      return Color.orange
    case .expert:
      return Color.red
    case .master:
      return Color.purple
    }
  }
}

#Preview {
  PuzzleCreationView()
}
