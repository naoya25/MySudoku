import Combine
import Foundation
import SwiftUI

@MainActor
class GameBoardViewModel: ObservableObject {
  @Published var board = Board()
  @Published var selectedPosition: Position?
  @Published var isNoteMode = false
  @Published var gameState: GameState = .playing
  @Published var formattedElapsedTime: String = "00:00"
  @Published var incorrectPositions: Set<Position> = []

  private let timerService = TimerService()
  private var cancellables = Set<AnyCancellable>()

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

  init() {
    setupTimerBinding()
  }

  func startGameWithPuzzle(_ puzzle: SupabaseResponse) {
    board = Board(givenData: puzzle.givenData, solutionData: puzzle.solutionData)
    selectedPosition = nil
    isNoteMode = false
    gameState = .playing
    incorrectPositions.removeAll()
    timerService.reset()
    timerService.start()
  }

  private func loadNewPuzzle() async {
    do {
      board = try await SupabaseService.shared.fetchRandomPuzzle()
      selectedPosition = nil
      isNoteMode = false
      gameState = .playing
      incorrectPositions.removeAll()
      timerService.reset()
      timerService.start()
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
      timerService.pause()
    case .paused:
      gameState = .playing
      timerService.resume()
    case .completed:
      break
    }
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

      checkCellCorrectness(at: position)
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
        timerService.pause()
      }
    }
  }

  func getValidationResult() -> ValidationResult {
    return ValidationService.validateBoard(board)
  }

  private func setupTimerBinding() {
    timerService.$elapsedTime
      .map { self.timerService.formatTime($0) }
      .assign(to: &$formattedElapsedTime)
  }

  private func checkCellCorrectness(at position: Position) {
    if board.isCorrectValueAt(row: position.row, column: position.column) {
      incorrectPositions.remove(position)
    } else {
      if let cell = board.cellAt(row: position.row, column: position.column),
        cell.displayValue != nil
      {
        incorrectPositions.insert(position)
      } else {
        incorrectPositions.remove(position)
      }
    }
  }

  func refreshAllCellCorrectness() {
    incorrectPositions.removeAll()
    for row in 0..<9 {
      for column in 0..<9 {
        let position = Position(row: row, column: column)
        if let cell = board.cellAt(row: row, column: column),
          cell.displayValue != nil,
          !board.isCorrectValueAt(row: row, column: column)
        {
          incorrectPositions.insert(position)
        }
      }
    }
  }

  func fillObviousCells() {
    let filledCells = SolutionService.fillObviousCells(board: &board)

    for (position, _) in filledCells {
      checkCellCorrectness(at: position)
    }

    if !filledCells.isEmpty {
      checkGameCompletion()
    }
  }

  func fillAllNotes() {
    let _ = SolutionService.fillAllNotes(board: &board)
  }

  func applyHiddenSingles() {
    let foundSingles = SolutionService.findHiddenSingles(board: &board)

    for (position, _) in foundSingles {
      checkCellCorrectness(at: position)
    }

    if !foundSingles.isEmpty {
      checkGameCompletion()
    }
  }
}
