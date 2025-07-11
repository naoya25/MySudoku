import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List {
      Section {
        NavigationLink(destination: PuzzleCreationView()) {
          HStack {
            Image(systemName: "square.grid.3x3")
              .foregroundColor(.blue)
              .frame(width: 20, height: 20)
            Text("ナンプレ問題作成")
          }
        }
      } header: {
        Text("管理機能")
      }
    }
    .navigationTitle("設定")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  SettingsView()
}
