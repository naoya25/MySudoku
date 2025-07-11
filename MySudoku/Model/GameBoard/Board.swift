import Foundation

struct Board: Codable {
  var cells: [Cell]
  var startDate: Date
  var moves: [Move] = []

  init() {
    self.cells = Array(repeating: Cell(), count: 81)
    self.startDate = Date()
  }

  init(cells: [Cell]) {
    precondition(cells.count == 81, "Board must have exactly 81 cells")
    self.cells = cells
    self.startDate = Date()
  }

  func cellAt(row: Int, column: Int) -> Cell? {
    guard row >= 0 && row < 9 && column >= 0 && column < 9 else { return nil }
    return cells[row * 9 + column]
  }

  mutating func setCellAt(row: Int, column: Int, cell: Cell) {
    guard row >= 0 && row < 9 && column >= 0 && column < 9 else { return }
    cells[row * 9 + column] = cell
  }

  func indexFor(row: Int, column: Int) -> Int? {
    guard row >= 0 && row < 9 && column >= 0 && column < 9 else { return nil }
    return row * 9 + column
  }

  func positionFor(index: Int) -> (row: Int, column: Int)? {
    guard index >= 0 && index < 81 else { return nil }
    return (row: index / 9, column: index % 9)
  }

  func blockIndexFor(row: Int, column: Int) -> Int? {
    guard row >= 0 && row < 9 && column >= 0 && column < 9 else { return nil }
    return (row / 3) * 3 + (column / 3)
  }

  func cellsInRow(_ row: Int) -> [Cell] {
    guard row >= 0 && row < 9 else { return [] }
    let startIndex = row * 9
    return Array(cells[startIndex..<startIndex + 9])
  }

  func cellsInColumn(_ column: Int) -> [Cell] {
    guard column >= 0 && column < 9 else { return [] }
    return stride(from: column, to: 81, by: 9).map { cells[$0] }
  }

  func cellsInBlock(_ blockIndex: Int) -> [Cell] {
    guard blockIndex >= 0 && blockIndex < 9 else { return [] }

    let blockRow = blockIndex / 3
    let blockColumn = blockIndex % 3
    let startRow = blockRow * 3
    let startColumn = blockColumn * 3

    var blockCells: [Cell] = []
    for r in startRow..<startRow + 3 {
      for c in startColumn..<startColumn + 3 {
        if let cell = cellAt(row: r, column: c) {
          blockCells.append(cell)
        }
      }
    }
    return blockCells
  }

  func cellsInBlockContaining(row: Int, column: Int) -> [Cell] {
    guard let blockIndex = blockIndexFor(row: row, column: column) else { return [] }
    return cellsInBlock(blockIndex)
  }

  mutating func addMove(_ move: Move) {
    moves.append(move)
  }

  var isComplete: Bool {
    return cells.allSatisfy { $0.displayValue != nil }
  }

  var elapsedTime: TimeInterval {
    return Date().timeIntervalSince(startDate)
  }
}
