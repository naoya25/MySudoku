import SwiftUI

struct SudokuGrid: View {
  let board: Board
  let selectedPosition: Position?
  let validationResult: ValidationResult
  let incorrectPositions: Set<Position>
  let onCellTap: (Position) -> Void

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<9, id: \.self) { row in
        HStack(spacing: 0) {
          ForEach(0..<9, id: \.self) { column in
            let cell = board.cellAt(row: row, column: column) ?? Cell()
            let position = Position(row: row, column: column)
            let isSelected = selectedPosition == position
            let hasError = validationResult.errorPositions.contains(position)
            let isIncorrect = incorrectPositions.contains(position)
            let isHighlighted = isPositionHighlighted(position)
            let hasSameNumber = hasSameNumberAsSelected(cell: cell)

            CellView(
              cell: cell,
              isSelected: isSelected,
              hasError: hasError,
              isIncorrect: isIncorrect,
              isHighlighted: isHighlighted,
              hasSameNumber: hasSameNumber,
              onTap: {
                onCellTap(position)
              }
            )
            .overlay(
              GeometryReader { geometry in
                Path { path in
                  let rect = CGRect(origin: .zero, size: geometry.size)

                  // 上辺
                  if row % 3 == 0 && row != 0 {
                    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                  }

                  // 右辺
                  if column % 3 == 2 && column != 8 {
                    path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                  }

                  // 下辺
                  if row % 3 == 2 && row != 8 {
                    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                  }

                  // 左辺
                  if column % 3 == 0 && column != 0 {
                    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                  }
                }
                .stroke(Color.black, lineWidth: 2)

                // 通常の細い枠線
                Rectangle()
                  .stroke(Color.gray, lineWidth: 0.5)
              }
            )
          }
        }
      }
    }
    .overlay(
      Rectangle()
        .stroke(Color.black, lineWidth: 2)
    )
    .aspectRatio(1, contentMode: .fit)
  }

  private func isPositionHighlighted(_ position: Position) -> Bool {
    guard let selected = selectedPosition else { return false }

    // 同じ行か列にある場合
    if position.row == selected.row || position.column == selected.column {
      return true
    }

    // 同じ3x3ブロックにある場合
    let selectedBlockRow = selected.row / 3
    let selectedBlockColumn = selected.column / 3
    let positionBlockRow = position.row / 3
    let positionBlockColumn = position.column / 3

    return selectedBlockRow == positionBlockRow && selectedBlockColumn == positionBlockColumn
  }

  private func hasSameNumberAsSelected(cell: Cell) -> Bool {
    guard let selected = selectedPosition else { return false }

    // 選択されたセルの値を取得
    if let selectedCell = board.cellAt(row: selected.row, column: selected.column),
      let selectedValue = selectedCell.displayValue,
      let cellValue = cell.displayValue,
      selectedValue == cellValue && selectedValue != 0
    {
      return true
    }

    return false
  }
}
