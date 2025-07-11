import Foundation

struct ValidationService {
  static func validateBoard(_ board: Board) -> ValidationResult {
    var errorPositions: Set<Position> = []

    for row in 0..<9 {
      let rowErrors = validateRow(board, row: row)
      errorPositions.formUnion(rowErrors)
    }

    for column in 0..<9 {
      let columnErrors = validateColumn(board, column: column)
      errorPositions.formUnion(columnErrors)
    }

    for blockIndex in 0..<9 {
      let blockErrors = validateBlock(board, blockIndex: blockIndex)
      errorPositions.formUnion(blockErrors)
    }

    return ValidationResult(
      isValid: errorPositions.isEmpty,
      errorPositions: errorPositions
    )
  }

  private static func validateRow(_ board: Board, row: Int) -> Set<Position> {
    var errorPositions: Set<Position> = []
    var valuePositions: [Int: [Position]] = [:]

    for column in 0..<9 {
      if let cell = board.cellAt(row: row, column: column),
        let value = cell.displayValue
      {
        let position = Position(row: row, column: column)

        if valuePositions[value] == nil {
          valuePositions[value] = []
        }
        valuePositions[value]?.append(position)
      }
    }

    for positions in valuePositions.values {
      if positions.count > 1 {
        errorPositions.formUnion(positions)
      }
    }

    return errorPositions
  }

  private static func validateColumn(_ board: Board, column: Int) -> Set<Position> {
    var errorPositions: Set<Position> = []
    var valuePositions: [Int: [Position]] = [:]

    for row in 0..<9 {
      if let cell = board.cellAt(row: row, column: column),
        let value = cell.displayValue
      {
        let position = Position(row: row, column: column)

        if valuePositions[value] == nil {
          valuePositions[value] = []
        }
        valuePositions[value]?.append(position)
      }
    }

    for positions in valuePositions.values {
      if positions.count > 1 {
        errorPositions.formUnion(positions)
      }
    }

    return errorPositions
  }

  private static func validateBlock(_ board: Board, blockIndex: Int) -> Set<Position> {
    var errorPositions: Set<Position> = []
    var valuePositions: [Int: [Position]] = [:]

    let blockRow = blockIndex / 3
    let blockColumn = blockIndex % 3
    let startRow = blockRow * 3
    let startColumn = blockColumn * 3

    for r in startRow..<startRow + 3 {
      for c in startColumn..<startColumn + 3 {
        if let cell = board.cellAt(row: r, column: c),
          let value = cell.displayValue
        {
          let position = Position(row: r, column: c)

          if valuePositions[value] == nil {
            valuePositions[value] = []
          }
          valuePositions[value]?.append(position)
        }
      }
    }

    for positions in valuePositions.values {
      if positions.count > 1 {
        errorPositions.formUnion(positions)
      }
    }

    return errorPositions
  }

  static func isValidMove(_ board: Board, row: Int, column: Int, value: Int) -> Bool {
    guard row >= 0 && row < 9 && column >= 0 && column < 9 else { return false }
    guard value >= 1 && value <= 9 else { return false }

    var tempBoard = board
    var tempCell = tempBoard.cellAt(row: row, column: column) ?? Cell()
    tempCell.value = value
    tempBoard.setCellAt(row: row, column: column, cell: tempCell)

    let result = validateBoard(tempBoard)
    let position = Position(row: row, column: column)

    return !result.errorPositions.contains(position)
  }
}

struct Position: Hashable, Codable {
  let row: Int
  let column: Int
}

struct ValidationResult {
  let isValid: Bool
  let errorPositions: Set<Position>
}
