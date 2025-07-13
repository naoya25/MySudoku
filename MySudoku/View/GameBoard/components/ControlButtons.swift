import SwiftUI

struct ControlButtons: View {
  let isNoteMode: Bool
  let onUndo: () -> Void
  let onToggleNoteMode: () -> Void
  let onClear: () -> Void
  let onShortcut: () -> Void

  var body: some View {
    HStack(spacing: 10) {
      Button("戻す") {
        onUndo()
      }
      .font(.callout)
      .foregroundColor(.blue)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(Color.blue.opacity(0.1))
      .cornerRadius(8)

      Button("ノート") {
        onToggleNoteMode()
      }
      .font(.callout)
      .foregroundColor(isNoteMode ? .white : .blue)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(isNoteMode ? Color.blue : Color.blue.opacity(0.1))
      .cornerRadius(8)

      Button("クリア") {
        onClear()
      }
      .font(.callout)
      .foregroundColor(.red)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(Color.red.opacity(0.1))
      .cornerRadius(8)
      
      Button(action: {
        onShortcut()
      }) {
        Image(systemName: "wand.and.stars")
          .font(.title3)
          .foregroundColor(.purple)
      }
      .frame(width: 44, height: 44)
      .background(Color.purple.opacity(0.1))
      .cornerRadius(8)
    }
  }
}
