import Foundation
import SwiftUI

@MainActor
class GameBoardViewModel: ObservableObject {
  @Published var board = Board()
  @Published var selectedPosition: Position?
  @Published var isNoteMode = false
  @Published var gameState: GameState = .playing

  enum GameState {
    case playing
    case paused
    case completed
  }

  func startNewGame() {
    board = createMockBoard()
    selectedPosition = nil
    isNoteMode = false
    gameState = .playing
  }

  private func createMockBoard() -> Board {
    // 実際のナンプレパズルの例
    let givenValues: [(row: Int, column: Int, value: Int)] = [
      // 1行目
      (0, 0, 5), (0, 1, 3), (0, 4, 7),
      // 2行目
      (1, 0, 6), (1, 3, 1), (1, 4, 9), (1, 5, 5),
      // 3行目
      (2, 1, 9), (2, 2, 8), (2, 7, 6),
      // 4行目
      (3, 0, 8), (3, 4, 6), (3, 8, 3),
      // 5行目
      (4, 0, 4), (4, 3, 8), (4, 5, 3), (4, 8, 1),
      // 6行目
      (5, 0, 7), (5, 4, 2), (5, 8, 6),
      // 7行目
      (6, 1, 6), (6, 6, 2), (6, 7, 8),
      // 8行目
      (7, 3, 4), (7, 4, 1), (7, 5, 9), (7, 8, 5),
      // 9行目
      (8, 4, 8), (8, 7, 7), (8, 8, 9),
    ]

    var cells: [Cell] = []
    for row in 0..<9 {
      for column in 0..<9 {
        var cell = Cell()

        // 与えられた数字をチェック
        if let given = givenValues.first(where: { $0.row == row && $0.column == column }) {
          cell.given = given.value
        }

        cells.append(cell)
      }
    }

    return Board(cells: cells)
  }

  func selectCell(at position: Position) {
    selectedPosition = position
  }

  func enterNumber(_ number: Int) {
    guard let position = selectedPosition,
      let cellIndex = board.indexFor(row: position.row, column: position.column),
      cellIndex < board.cells.count
    else { return }

    let cell = board.cells[cellIndex]
    guard !cell.isGiven else { return }

    let previousValue = cell.value
    let previousMarks = cell.pencilMarks

    if isNoteMode {
      var newCell = cell
      if newCell.pencilMarks.contains(number) {
        newCell.pencilMarks.remove(number)
      } else {
        newCell.pencilMarks.insert(number)
      }

      let move = Move(
        cellID: cell.id,
        previousValue: previousValue,
        newValue: previousValue,
        previousMarks: previousMarks,
        newMarks: newCell.pencilMarks
      )

      board.cells[cellIndex] = newCell
      board.addMove(move)
    } else {
      var newCell = cell
      newCell.value = (cell.value == number) ? nil : number
      newCell.pencilMarks.removeAll()

      let move = Move(
        cellID: cell.id,
        previousValue: previousValue,
        newValue: newCell.value,
        previousMarks: previousMarks,
        newMarks: newCell.pencilMarks
      )

      board.cells[cellIndex] = newCell
      board.addMove(move)
    }

    checkGameCompletion()
  }

  func toggleNoteMode() {
    isNoteMode.toggle()
  }

  func clearCell() {
    guard let position = selectedPosition,
      let cellIndex = board.indexFor(row: position.row, column: position.column),
      cellIndex < board.cells.count
    else { return }

    let cell = board.cells[cellIndex]
    guard !cell.isGiven else { return }

    let previousValue = cell.value
    let previousMarks = cell.pencilMarks

    var newCell = cell
    newCell.value = nil
    newCell.pencilMarks.removeAll()

    let move = Move(
      cellID: cell.id,
      previousValue: previousValue,
      newValue: nil,
      previousMarks: previousMarks,
      newMarks: []
    )

    board.cells[cellIndex] = newCell
    board.addMove(move)
  }

  private func checkGameCompletion() {
    if board.isComplete {
      let validationResult = ValidationService.validateBoard(board)
      if validationResult.isValid {
        gameState = .completed
      }
    }
  }

  func getValidationResult() -> ValidationResult {
    return ValidationService.validateBoard(board)
  }
}
