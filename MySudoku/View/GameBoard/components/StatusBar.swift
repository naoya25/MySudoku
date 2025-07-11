import SwiftUI

struct StatusBar: View {
  let elapsedTime: String
  let errorCount: Int
  let maxErrors: Int
  let isPaused: Bool
  let onPauseToggle: () -> Void

  var body: some View {
    HStack {
      // タイマー表示
      HStack(spacing: 4) {
        Image(systemName: "clock")
          .foregroundColor(.secondary)
        Text(elapsedTime)
          .font(.title3)
          .fontWeight(.medium)
      }

      Spacer()

      // 一時停止ボタン
      Button(action: {
        onPauseToggle()
      }) {
        Image(systemName: isPaused ? "play.fill" : "pause.fill")
          .font(.title3)
          .foregroundColor(.blue)
      }
      .buttonStyle(PlainButtonStyle())

      Spacer()

      // 間違い数表示
      HStack(spacing: 4) {
        Image(systemName: "xmark.circle")
          .foregroundColor(.red)
        Text("\(errorCount)/\(maxErrors)")
          .font(.title3)
          .fontWeight(.medium)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 15)
  }
}
