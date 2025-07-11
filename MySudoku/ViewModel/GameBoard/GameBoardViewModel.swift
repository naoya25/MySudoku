import Foundation
import SwiftUI

@MainActor
class GameBoardViewModel: ObservableObject {
  @Published var board = Board()
  @Published var selectedPosition: Position?
  @Published var isNoteMode = false
  @Published var gameState: GameState = .playing

  enum GameState {
    case error
    case playing
    case paused
    case completed
  }

  func startNewGame() {
    Task {
      await loadNewPuzzle()
    }
  }

  private func loadNewPuzzle() async {
    do {
      board = try await SupabaseService.shared.fetchRandomPuzzle()
      selectedPosition = nil
      isNoteMode = false
      gameState = .playing
    } catch {
      print(
        "Failed to load puzzle from Supabase: \(error.localizedDescription)"
      )

      selectedPosition = nil
      isNoteMode = false
      gameState = .error
    }
  }

  func togglePause() {
    switch gameState {
    case .error:
      break
    case .playing:
      gameState = .paused
    case .paused:
      gameState = .playing
    case .completed:
      break
    }
  }

  // private func createMockBoard() -> Board {
  //   // 問題盤面：0は空欄、1-9は与えられた数字（81文字）
  //   let givenData =
  //     "530007000600195000098000060800060003400803001700020006060000280000419005000080079"

  //   // 完全な解答（81文字）
  //   let solutionData =
  //     "534678912672195348198342567859761423426853791713924856961537284287419635345286179"

  //   return Board(givenData: givenData, solutionData: solutionData)
  // }

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
