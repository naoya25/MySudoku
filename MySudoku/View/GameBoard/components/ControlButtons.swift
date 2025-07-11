import SwiftUI

struct ControlButtons: View {
  let isNoteMode: Bool
  let onUndo: () -> Void
  let onToggleNoteMode: () -> Void
  let onClear: () -> Void

  var body: some View {
    HStack(spacing: 15) {
      Button("戻す") {
        onUndo()
      }
      .font(.title3)
      .foregroundColor(.blue)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(Color.blue.opacity(0.1))
      .cornerRadius(8)

      Button("ノートモード") {
        onToggleNoteMode()
      }
      .font(.title3)
      .foregroundColor(isNoteMode ? .white : .blue)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(isNoteMode ? Color.blue : Color.blue.opacity(0.1))
      .cornerRadius(8)

      Button("クリア") {
        onClear()
      }
      .font(.title3)
      .foregroundColor(.red)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(Color.red.opacity(0.1))
      .cornerRadius(8)
    }
  }
}
