import Foundation

// MARK: - 難易度計算サービス
class DifficultyCalculatorService {
  static let shared = DifficultyCalculatorService()

  private init() {}

  // MARK: - 基本難易度計算
  func calculateBasicDifficulty(emptyCount: Int) -> Int {
    return 1000 + (emptyCount * 25)
  }

  // MARK: - 解法技術による難易度計算
  func calculateDifficultyWithTechniques(puzzle: String, solution: String) -> DifficultyResult {
    let emptyCount = puzzle.filter { $0 == "0" }.count
    let basicDifficulty = calculateBasicDifficulty(emptyCount: emptyCount)

    // 解法プロセスをシミュレート
    let solvingSteps = simulateSolvingProcess(puzzle: puzzle, solution: solution)

    // 技術レベルによる追加難易度を計算
    let techniqueBonus = calculateTechniqueBonus(steps: solvingSteps)

    let finalDifficulty = basicDifficulty + techniqueBonus

    return DifficultyResult(
      difficulty: finalDifficulty,
      rank: getDifficultyRank(difficulty: finalDifficulty),
      emptyCount: emptyCount,
      solvingSteps: solvingSteps,
      expectedSolvingTime: getExpectedSolvingTime(difficulty: finalDifficulty)
    )
  }

  // MARK: - 解法プロセスのシミュレート
  private func simulateSolvingProcess(puzzle: String, solution: String) -> [SolvingStep] {
    var currentBoard = Array(puzzle)
    let targetBoard = Array(solution)
    var steps: [SolvingStep] = []

    // 簡単な解法プロセスをシミュレート
    while String(currentBoard) != String(targetBoard) {
      let step = findNextSolvingStep(currentBoard: currentBoard, targetBoard: targetBoard)
      if let step = step {
        currentBoard[step.cellIndex] = Character(String(step.value))
        steps.append(step)
      } else {
        // 解法が見つからない場合は推測技術を使用
        let guessStep = createGuessStep(currentBoard: currentBoard, targetBoard: targetBoard)
        if let guessStep = guessStep {
          currentBoard[guessStep.cellIndex] = Character(String(guessStep.value))
          steps.append(guessStep)
        } else {
          break
        }
      }
    }

    return steps
  }

  private func findNextSolvingStep(currentBoard: [Character], targetBoard: [Character])
    -> SolvingStep?
  {
    for i in 0..<81 {
      if currentBoard[i] == "0" {
        let candidates = getCandidates(board: currentBoard, index: i)
        let correctValue = Int(String(targetBoard[i]))!

        if candidates.count == 1 && candidates.contains(correctValue) {
          // 裸のシングル
          return SolvingStep(
            cellIndex: i,
            value: correctValue,
            techniqueLevel: 1,
            candidatesBefore: candidates,
            candidatesAfter: Set([correctValue])
          )
        } else if isHiddenSingle(board: currentBoard, index: i, value: correctValue) {
          // 隠れたシングル
          return SolvingStep(
            cellIndex: i,
            value: correctValue,
            techniqueLevel: 2,
            candidatesBefore: candidates,
            candidatesAfter: Set([correctValue])
          )
        }
      }
    }
    return nil
  }

  private func createGuessStep(currentBoard: [Character], targetBoard: [Character]) -> SolvingStep?
  {
    for i in 0..<81 {
      if currentBoard[i] == "0" {
        let candidates = getCandidates(board: currentBoard, index: i)
        let correctValue = Int(String(targetBoard[i]))!

        return SolvingStep(
          cellIndex: i,
          value: correctValue,
          techniqueLevel: 10,  // 推測・試行錯誤
          candidatesBefore: candidates,
          candidatesAfter: Set([correctValue])
        )
      }
    }
    return nil
  }

  private func getCandidates(board: [Character], index: Int) -> Set<Int> {
    let row = index / 9
    let col = index % 9
    let blockStartRow = (row / 3) * 3
    let blockStartCol = (col / 3) * 3

    var usedNumbers: Set<Int> = []

    // 行をチェック
    for c in 0..<9 {
      let char = board[row * 9 + c]
      if char != "0", let num = Int(String(char)) {
        usedNumbers.insert(num)
      }
    }

    // 列をチェック
    for r in 0..<9 {
      let char = board[r * 9 + col]
      if char != "0", let num = Int(String(char)) {
        usedNumbers.insert(num)
      }
    }

    // 3x3ブロックをチェック
    for r in blockStartRow..<(blockStartRow + 3) {
      for c in blockStartCol..<(blockStartCol + 3) {
        let char = board[r * 9 + c]
        if char != "0", let num = Int(String(char)) {
          usedNumbers.insert(num)
        }
      }
    }

    return Set(1...9).subtracting(usedNumbers)
  }

  private func isHiddenSingle(board: [Character], index: Int, value: Int) -> Bool {
    let row = index / 9
    let col = index % 9
    let blockStartRow = (row / 3) * 3
    let blockStartCol = (col / 3) * 3

    // 行で他に同じ値が入る場所があるかチェック
    var rowPossibilities = 0
    for c in 0..<9 {
      let cellIndex = row * 9 + c
      if board[cellIndex] == "0" {
        let candidates = getCandidates(board: board, index: cellIndex)
        if candidates.contains(value) {
          rowPossibilities += 1
        }
      }
    }

    if rowPossibilities == 1 {
      return true
    }

    // 列で他に同じ値が入る場所があるかチェック
    var colPossibilities = 0
    for r in 0..<9 {
      let cellIndex = r * 9 + col
      if board[cellIndex] == "0" {
        let candidates = getCandidates(board: board, index: cellIndex)
        if candidates.contains(value) {
          colPossibilities += 1
        }
      }
    }

    if colPossibilities == 1 {
      return true
    }

    // 3x3ブロックで他に同じ値が入る場所があるかチェック
    var blockPossibilities = 0
    for r in blockStartRow..<(blockStartRow + 3) {
      for c in blockStartCol..<(blockStartCol + 3) {
        let cellIndex = r * 9 + c
        if board[cellIndex] == "0" {
          let candidates = getCandidates(board: board, index: cellIndex)
          if candidates.contains(value) {
            blockPossibilities += 1
          }
        }
      }
    }

    return blockPossibilities == 1
  }

  // MARK: - 技術レベルによる追加難易度計算
  private func calculateTechniqueBonus(steps: [SolvingStep]) -> Int {
    let techniqueCounts = Dictionary(grouping: steps, by: { $0.techniqueLevel })
      .mapValues { $0.count }

    var bonus = 0
    for (level, count) in techniqueCounts {
      let coefficient = getTechniqueCoefficient(level: level)
      bonus += Int(coefficient * Double(count))
    }

    return bonus
  }

  private func getTechniqueCoefficient(level: Int) -> Double {
    switch level {
    case 1: return 1.0  // 裸のシングル
    case 2: return 1.5  // 隠れたシングル
    case 3: return 2.0  // 裸のペア
    case 4: return 2.5  // 隠れたペア
    case 5: return 3.0  // 裸のトリプル
    case 6: return 3.5  // 隠れたトリプル
    case 7: return 4.0  // ポインティングペア
    case 8: return 4.5  // ボックス/ライン削減
    case 9: return 5.0  // X-Wing
    case 10: return 10.0  // 推測・試行錯誤
    default: return 1.0
    }
  }

  // MARK: - 難易度ランク判定
  private func getDifficultyRank(difficulty: Int) -> DifficultyRank {
    switch difficulty {
    case 1000..<1500: return .beginner
    case 1500..<2000: return .intermediate
    case 2000..<2500: return .advanced
    case 2500..<3000: return .expert
    default: return .master
    }
  }

  // MARK: - 期待解答時間計算
  private func getExpectedSolvingTime(difficulty: Int) -> TimeInterval {
    switch difficulty {
    case 1000..<1500: return 300  // 5分
    case 1500..<2000: return 600  // 10分
    case 2000..<2500: return 1200  // 20分
    case 2500..<3000: return 1800  // 30分
    default: return 2400  // 40分
    }
  }

  // MARK: - 動的難易度調整
  func adjustDifficulty(
    currentDifficulty: Int, solvingTime: TimeInterval, expectedTime: TimeInterval
  ) -> Int {
    let ratio = solvingTime / expectedTime
    let adjustment = Int((ratio - 1.0) * 100)
    return max(1000, min(5000, currentDifficulty + adjustment))
  }
}

// MARK: - データ構造
struct SolvingStep {
  let cellIndex: Int
  let value: Int
  let techniqueLevel: Int
  let candidatesBefore: Set<Int>
  let candidatesAfter: Set<Int>
}

struct DifficultyResult {
  let difficulty: Int
  let rank: DifficultyRank
  let emptyCount: Int
  let solvingSteps: [SolvingStep]
  let expectedSolvingTime: TimeInterval
}

enum DifficultyRank: Int, CaseIterable {
  case beginner = 1
  case intermediate = 2
  case advanced = 3
  case expert = 4
  case master = 5

  var name: String {
    switch self {
    case .beginner: return "初級"
    case .intermediate: return "中級"
    case .advanced: return "上級"
    case .expert: return "エキスパート"
    case .master: return "マスター"
    }
  }

  var description: String {
    switch self {
    case .beginner: return "基本的な解法のみ"
    case .intermediate: return "ペア・トリプル技術が必要"
    case .advanced: return "高度な論理技術が必要"
    case .expert: return "複雑な解法パターンが必要"
    case .master: return "推測・試行錯誤が必要"
    }
  }
}
