import SwiftUI

struct PuzzleCreationView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 20) {
      Text("ナンプレ問題作成")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)

      Spacer()

      Text("ここに問題作成機能を実装予定")
        .font(.title2)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Spacer()
    }
    .navigationTitle("問題作成")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  PuzzleCreationView()
}
