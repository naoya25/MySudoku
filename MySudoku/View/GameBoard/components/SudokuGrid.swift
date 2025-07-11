import SwiftUI

struct SudokuGrid: View {
  let board: Board
  let selectedPosition: Position?
  let validationResult: ValidationResult
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

            CellView(
              cell: cell,
              isSelected: isSelected,
              hasError: hasError,
              onTap: {
                onCellTap(position)
              }
            )
            .overlay(
              Rectangle()
                .stroke(Color.black, lineWidth: 2)
            )
          }
        }
      }
    }
    .overlay(
      Rectangle()
        .stroke(Color.black, lineWidth: 1)
    )
    .aspectRatio(1, contentMode: .fit)
  }Ï
}
