import SwiftUI

struct PuzzleListView: View {
  @ObservedObject var viewModel: HomeViewModel

  var body: some View {
    NavigationView {
      VStack {
        if viewModel.isLoadingPuzzles {
          Spacer()
          ProgressView("パズルを読み込み中...")
            .padding()
          Spacer()
        } else if let errorMessage = viewModel.errorMessage {
          VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 48))
              .foregroundColor(.red)

            Text("エラーが発生しました")
              .font(.title2)
              .fontWeight(.bold)

            Text(errorMessage)
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)

            Button("再試行") {
              viewModel.loadPuzzles()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
          }
          .padding()
        } else {
          List(viewModel.puzzles, id: \.id) { puzzle in
            PuzzleListItem(puzzle: puzzle) {
              viewModel.startGameWithPuzzle(puzzle)
            }
          }
          .listStyle(PlainListStyle())
        }
      }
      .navigationTitle("パズルを選択")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("キャンセル") {
            viewModel.showingPuzzleList = false
          }
        }
      }
    }
  }
}
