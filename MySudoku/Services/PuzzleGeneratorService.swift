import Foundation

class PuzzleGeneratorService {
  static let shared = PuzzleGeneratorService()

  private init() {}

  // MARK: - メイン生成メソッド
  func generatePuzzle() -> (puzzle: String, solution: String) {
    print("=== ナンプレ生成開始 ===")

    // ステップ1: 3つのランダムな3x3ブロックで初期盤面を作成
    let initialBoard = createInitialBoard()

    // ステップ2: 盤面を解いて完全な解答を取得
    guard let solution = solvePuzzle(initialBoard) else {
      print("解答が見つからないため、再試行します")
      return generatePuzzle()
    }

    print("完全な解答:")
    printBoard(solution)

    // ステップ3: 一意解を保ちながらセルを削除してパズルを作成
    let puzzle = createPuzzleFromSolution(solution)

    print("最終的なパズル:")
    printBoard(puzzle)

    let emptyCount = puzzle.filter { $0 == "0" }.count
    print("空のセル数: \(emptyCount)")

    // 難易度を計算
    let difficultyResult = DifficultyCalculatorService.shared.calculateDifficultyWithTechniques(
      puzzle: puzzle,
      solution: solution
    )

    print("難易度: \(difficultyResult.difficulty) (\(difficultyResult.rank.name))")
    print("期待解答時間: \(Int(difficultyResult.expectedSolvingTime / 60))分")
    print("=== ナンプレ生成完了 ===")

    return (puzzle: puzzle, solution: solution)
  }

  // MARK: - ステップ1: 初期盤面作成
  private func createInitialBoard() -> String {
    var board = Array(repeating: "0", count: 81)

    // 左上3x3ブロックを埋める（インデックス 0-2, 9-11, 18-20）
    fillBlock(board: &board, startRow: 0, startCol: 0)

    // 中央3x3ブロックを埋める（インデックス 30-32, 39-41, 48-50）
    fillBlock(board: &board, startRow: 3, startCol: 3)

    // 右下3x3ブロックを埋める（インデックス 60-62, 69-71, 78-80）
    fillBlock(board: &board, startRow: 6, startCol: 6)

    return board.joined()
  }

  private func fillBlock(board: inout [String], startRow: Int, startCol: Int) {
    var numbers = Array(1...9).map { String($0) }
    numbers.shuffle()

    var index = 0
    for row in startRow..<(startRow + 3) {
      for col in startCol..<(startCol + 3) {
        let boardIndex = row * 9 + col
        board[boardIndex] = numbers[index]
        index += 1
      }
    }
  }

  // MARK: - ステップ2: パズル解答（v4アルゴリズム）
  func solvePuzzle(_ boardString: String) -> String? {
    var board = Array(boardString)

    if !isValidBoard(board) {
      return nil
    }

    // DFSを使用して解答を見つける
    var solutions: [String] = []
    solveDFS(
      board: &board, emptyCount: boardString.filter { $0 == "0" }.count, currentEmpty: 0,
      solutions: &solutions)

    return solutions.first
  }

  private func solveDFS(
    board: inout [Character], emptyCount: Int, currentEmpty: Int, solutions: inout [String]
  ) {
    // すでに解答が見つかっている場合は停止（効率のため）
    if !solutions.isEmpty {
      return
    }

    if currentEmpty == emptyCount {
      // 完全な解答を発見
      solutions.append(String(board))
      return
    }

    // 最小の可能性を持つ次の空のセルを見つける
    let (nextIndex, possibilities) = findNextCell(board)

    for number in possibilities {
      board[nextIndex] = Character(number)
      solveDFS(
        board: &board, emptyCount: emptyCount, currentEmpty: currentEmpty + 1, solutions: &solutions
      )
      board[nextIndex] = "0"
    }
  }

  private func findNextCell(_ board: [Character]) -> (Int, [String]) {
    var bestIndex = 0
    var maxConstraints = 0
    var bestPossibilities: Set<String> = []

    for i in 0..<81 {
      if board[i] != "0" {
        continue
      }

      let row = i / 9
      let col = i % 9
      let blockStartRow = (row / 3) * 3
      let blockStartCol = (col / 3) * 3

      var usedNumbers: Set<String> = []

      // 行をチェック
      for c in 0..<9 {
        let char = board[row * 9 + c]
        if char != "0" {
          usedNumbers.insert(String(char))
        }
      }

      // 列をチェック
      for r in 0..<9 {
        let char = board[r * 9 + col]
        if char != "0" {
          usedNumbers.insert(String(char))
        }
      }

      // 3x3ブロックをチェック
      for r in blockStartRow..<(blockStartRow + 3) {
        for c in blockStartCol..<(blockStartCol + 3) {
          let char = board[r * 9 + c]
          if char != "0" {
            usedNumbers.insert(String(char))
          }
        }
      }

      let possibilities = Set(["1", "2", "3", "4", "5", "6", "7", "8", "9"]).subtracting(
        usedNumbers)

      if usedNumbers.count > maxConstraints {
        maxConstraints = usedNumbers.count
        bestIndex = i
        bestPossibilities = possibilities
      }
    }

    return (bestIndex, Array(bestPossibilities))
  }

  // MARK: - ステップ3: セルを削除してパズルを作成
  private func createPuzzleFromSolution(_ solution: String) -> String {
    var puzzle = Array(solution)
    var removedIndices: [Int] = []

    // 全てのインデックスを取得してシャッフル
    var allIndices = Array(0..<81)
    allIndices.shuffle()

    for index in allIndices {
      // このセルを削除してみる
      let originalValue = puzzle[index]
      puzzle[index] = "0"
      removedIndices.append(index)

      // パズルがまだ一意解を持つかチェック
      if !hasUniqueSolution(String(puzzle), originalSolution: solution) {
        // 一意でない場合、セルを復元
        puzzle[index] = originalValue
        removedIndices.removeLast()
        print("セル \(index) を復元しました")
      } else {
        print("セル \(index) を削除しました（空のセル数: \(String(puzzle).filter { $0 == "0" }.count)）")
      }
    }

    return String(puzzle)
  }

  private func hasUniqueSolution(_ puzzleString: String, originalSolution: String) -> Bool {
    var board = Array(puzzleString)
    var solutions: [String] = []

    // 全ての解答を見つけるためのDFS（最大2つまで）
    solveDFSForValidation(
      board: &board,
      emptyCount: puzzleString.filter { $0 == "0" }.count,
      currentEmpty: 0,
      solutions: &solutions,
      maxSolutions: 2  // 2つ見つかったら十分（一意性の確認のため）
    )

    // 解答が1つだけで、かつ元の解答と一致する場合のみTrue
    return solutions.count == 1 && solutions.first == originalSolution
  }

  private func solveDFSForValidation(
    board: inout [Character],
    emptyCount: Int,
    currentEmpty: Int,
    solutions: inout [String],
    maxSolutions: Int
  ) {
    // 既に最大数の解答を見つけた場合は停止
    if solutions.count >= maxSolutions {
      return
    }

    if currentEmpty == emptyCount {
      // 完全な解答を発見
      solutions.append(String(board))
      return
    }

    // 最小の可能性を持つ次の空のセルを見つける
    let (nextIndex, possibilities) = findNextCell(board)

    for number in possibilities {
      board[nextIndex] = Character(number)
      solveDFSForValidation(
        board: &board,
        emptyCount: emptyCount,
        currentEmpty: currentEmpty + 1,
        solutions: &solutions,
        maxSolutions: maxSolutions
      )
      board[nextIndex] = "0"

      // 既に最大数の解答を見つけた場合は早期終了
      if solutions.count >= maxSolutions {
        return
      }
    }
  }

  // MARK: - バリデーションメソッド
  private func isValidBoard(_ board: [Character]) -> Bool {
    // 行をチェック
    for row in 0..<9 {
      if !isValidGroup(board, indices: (0..<9).map { row * 9 + $0 }) {
        return false
      }
    }

    // 列をチェック
    for col in 0..<9 {
      if !isValidGroup(board, indices: (0..<9).map { $0 * 9 + col }) {
        return false
      }
    }

    // 3x3ブロックをチェック
    for blockRow in 0..<3 {
      for blockCol in 0..<3 {
        var indices: [Int] = []
        for row in 0..<3 {
          for col in 0..<3 {
            indices.append((blockRow * 3 + row) * 9 + (blockCol * 3 + col))
          }
        }
        if !isValidGroup(board, indices: indices) {
          return false
        }
      }
    }

    return true
  }

  private func isValidGroup(_ board: [Character], indices: [Int]) -> Bool {
    var seen: Set<Character> = []

    for index in indices {
      let char = board[index]
      if char != "0" {
        if seen.contains(char) {
          return false
        }
        seen.insert(char)
      }
    }

    return true
  }

  // MARK: - デバッグ用メソッド
  func printBoard(_ boardString: String) {
    let board = Array(boardString)
    print("+-------+-------+-------+")
    for row in 0..<9 {
      var line = "| "
      for col in 0..<9 {
        let index = row * 9 + col
        let char = board[index]
        line += (char == "0" ? "." : String(char)) + " "
        if col % 3 == 2 {
          line += "| "
        }
      }
      print(line)
      if row % 3 == 2 {
        print("+-------+-------+-------+")
      }
    }
    print("")
  }

  // 生成されたパズルが正しく解けるかテスト
  func testGeneratedPuzzle() -> Bool {
    let (puzzle, solution) = generatePuzzle()

    // 生成されたパズルを解いてみる
    guard let testSolution = solvePuzzle(puzzle) else {
      print("❌ 生成されたパズルが解けません")
      return false
    }

    // 解答が一致するかチェック
    if testSolution == solution {
      print("✅ パズル生成とテスト成功!")
      return true
    } else {
      print("❌ 解答が一致しません")
      print("期待される解答: \(solution)")
      print("実際の解答: \(testSolution)")
      return false
    }
  }
}
