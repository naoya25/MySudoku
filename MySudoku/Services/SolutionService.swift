import Foundation

struct SolutionService {

  static func fillObviousCells(board: inout Board) -> [(position: Position, value: Int)] {
    var filledCells: [(position: Position, value: Int)] = []
    var hasChanges = true

    while hasChanges {
      hasChanges = false
      
      // 手順1: 数字ごとに、その数字が入るセルが1つに絞られるかチェック
      for number in 1...9 {
        // 行ごとにチェック
        for row in 0..<9 {
          var possiblePositions: [Position] = []
          
          for column in 0..<9 {
            let position = Position(row: row, column: column)
            if let cell = board.cellAt(row: row, column: column),
               cell.displayValue == nil {
              let candidates = getPossibleValues(for: position, in: board)
              if candidates.contains(number) {
                // 正解データと照合
                if let solutionCell = board.solutionCellAt(row: row, column: column),
                   let solutionValue = solutionCell.displayValue,
                   solutionValue == number {
                  possiblePositions.append(position)
                }
              }
            }
          }
          
          if possiblePositions.count == 1 {
            let position = possiblePositions[0]
            if let cellIndex = board.indexFor(row: position.row, column: position.column) {
              var cell = board.cells[cellIndex]
              cell.value = number
              board.cells[cellIndex] = cell
              filledCells.append((position: position, value: number))
              hasChanges = true
            }
          }
        }
        
        // 列ごとにチェック
        for column in 0..<9 {
          var possiblePositions: [Position] = []
          
          for row in 0..<9 {
            let position = Position(row: row, column: column)
            if let cell = board.cellAt(row: row, column: column),
               cell.displayValue == nil {
              let candidates = getPossibleValues(for: position, in: board)
              if candidates.contains(number) {
                // 正解データと照合
                if let solutionCell = board.solutionCellAt(row: row, column: column),
                   let solutionValue = solutionCell.displayValue,
                   solutionValue == number {
                  possiblePositions.append(position)
                }
              }
            }
          }
          
          if possiblePositions.count == 1 {
            let position = possiblePositions[0]
            if let cellIndex = board.indexFor(row: position.row, column: position.column),
               board.cells[cellIndex].value == nil {
              var cell = board.cells[cellIndex]
              cell.value = number
              board.cells[cellIndex] = cell
              filledCells.append((position: position, value: number))
              hasChanges = true
            }
          }
        }
        
        // ブロックごとにチェック
        for blockIndex in 0..<9 {
          var possiblePositions: [Position] = []
          let blockRow = blockIndex / 3
          let blockColumn = blockIndex % 3
          let startRow = blockRow * 3
          let startColumn = blockColumn * 3
          
          for r in startRow..<startRow + 3 {
            for c in startColumn..<startColumn + 3 {
              let position = Position(row: r, column: c)
              if let cell = board.cellAt(row: r, column: c),
                 cell.displayValue == nil {
                let candidates = getPossibleValues(for: position, in: board)
                if candidates.contains(number) {
                  // 正解データと照合
                  if let solutionCell = board.solutionCellAt(row: r, column: c),
                     let solutionValue = solutionCell.displayValue,
                     solutionValue == number {
                    possiblePositions.append(position)
                  }
                }
              }
            }
          }
          
          if possiblePositions.count == 1 {
            let position = possiblePositions[0]
            if let cellIndex = board.indexFor(row: position.row, column: position.column),
               board.cells[cellIndex].value == nil {
              var cell = board.cells[cellIndex]
              cell.value = number
              board.cells[cellIndex] = cell
              filledCells.append((position: position, value: number))
              hasChanges = true
            }
          }
        }
      }
    }

    return filledCells
  }

  static func getPossibleValues(for position: Position, in board: Board) -> Set<Int> {
    var possibleValues: Set<Int> = Set(1...9)

    let rowCells = board.cellsInRow(position.row)
    for cell in rowCells {
      if let value = cell.displayValue {
        possibleValues.remove(value)
      }
    }

    let columnCells = board.cellsInColumn(position.column)
    for cell in columnCells {
      if let value = cell.displayValue {
        possibleValues.remove(value)
      }
    }

    let blockCells = board.cellsInBlockContaining(row: position.row, column: position.column)
    for cell in blockCells {
      if let value = cell.displayValue {
        possibleValues.remove(value)
      }
    }

    return possibleValues
  }

  static func fillAllNotes(board: inout Board) -> Int {
    var notesAdded = 0

    for row in 0..<9 {
      for column in 0..<9 {
        let position = Position(row: row, column: column)

        guard let cellIndex = board.indexFor(row: row, column: column),
          let cell = board.cellAt(row: row, column: column),
          cell.displayValue == nil
        else {
          continue
        }

        let candidates = getPossibleValues(for: position, in: board)

        if !candidates.isEmpty {
          var newCell = cell
          newCell.pencilMarks = candidates
          board.cells[cellIndex] = newCell
          notesAdded += candidates.count
        }
      }
    }

    return notesAdded
  }

  static func findHiddenSingles(board: inout Board) -> [(position: Position, value: Int)] {
    var foundSingles: [(position: Position, value: Int)] = []

    for number in 1...9 {
      for row in 0..<9 {
        var possiblePositions: [Position] = []

        for column in 0..<9 {
          let position = Position(row: row, column: column)
          if let cell = board.cellAt(row: row, column: column),
            cell.displayValue == nil
          {
            let candidates = getPossibleValues(for: position, in: board)
            if candidates.contains(number) {
              possiblePositions.append(position)
            }
          }
        }

        if possiblePositions.count == 1 {
          let position = possiblePositions[0]
          if let cellIndex = board.indexFor(row: position.row, column: position.column) {
            var cell = board.cells[cellIndex]
            cell.value = number
            board.cells[cellIndex] = cell
            foundSingles.append((position: position, value: number))
          }
        }
      }

      for column in 0..<9 {
        var possiblePositions: [Position] = []

        for row in 0..<9 {
          let position = Position(row: row, column: column)
          if let cell = board.cellAt(row: row, column: column),
            cell.displayValue == nil
          {
            let candidates = getPossibleValues(for: position, in: board)
            if candidates.contains(number) {
              possiblePositions.append(position)
            }
          }
        }

        if possiblePositions.count == 1 {
          let position = possiblePositions[0]
          if let cellIndex = board.indexFor(row: position.row, column: position.column),
            board.cells[cellIndex].value == nil
          {
            var cell = board.cells[cellIndex]
            cell.value = number
            board.cells[cellIndex] = cell
            foundSingles.append((position: position, value: number))
          }
        }
      }

      for blockIndex in 0..<9 {
        var possiblePositions: [Position] = []
        let blockRow = blockIndex / 3
        let blockColumn = blockIndex % 3
        let startRow = blockRow * 3
        let startColumn = blockColumn * 3

        for r in startRow..<startRow + 3 {
          for c in startColumn..<startColumn + 3 {
            let position = Position(row: r, column: c)
            if let cell = board.cellAt(row: r, column: c),
              cell.displayValue == nil
            {
              let candidates = getPossibleValues(for: position, in: board)
              if candidates.contains(number) {
                possiblePositions.append(position)
              }
            }
          }
        }

        if possiblePositions.count == 1 {
          let position = possiblePositions[0]
          if let cellIndex = board.indexFor(row: position.row, column: position.column),
            board.cells[cellIndex].value == nil
          {
            var cell = board.cells[cellIndex]
            cell.value = number
            board.cells[cellIndex] = cell
            foundSingles.append((position: position, value: number))
          }
        }
      }
    }

    return foundSingles
  }
}
