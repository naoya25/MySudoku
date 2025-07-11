import SwiftUI

struct CellView: View {
  let cell: Cell
  let isSelected: Bool
  let hasError: Bool
  let isHighlighted: Bool
  let hasSameNumber: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: {
      withAnimation(nil) {
        onTap()
      }
    }) {
      ZStack {
        Rectangle()
          .fill(backgroundColor)
          .frame(width: 35, height: 35)

        if let value = cell.displayValue {
          Text("\(value)")
            .font(.title2)
            .fontWeight(cell.isGiven ? .bold : .regular)
            .foregroundColor(textColor)
        } else if !cell.pencilMarks.isEmpty {
          pencilMarksView
        }
      }
    }
    .buttonStyle(PlainButtonStyle())
    .transaction { transaction in
      transaction.animation = nil
    }
  }

  private var backgroundColor: Color {
    if hasError {
      return Color.red.opacity(0.3)
    } else if isSelected || hasSameNumber {
      return Color.blue.opacity(0.1)
    } else if isHighlighted {
      return Color.gray.opacity(0.1)
    } else {
      return Color.white
    }
  }

  private var textColor: Color {
    if hasError {
      return .red
    } else if cell.isGiven {
      return .black
    } else {
      return .blue
    }
  }

  private var pencilMarksView: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 3), spacing: 0) {
      ForEach(1...9, id: \.self) { number in
        Text(cell.pencilMarks.contains(number) ? "\(number)" : " ")
          .font(.system(size: 8))
          .foregroundColor(.gray)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .frame(width: 35, height: 35)
  }
}
