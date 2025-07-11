import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()

  var body: some View {
    NavigationView {
      ZStack {
        Color.blue.opacity(0.1)
          .ignoresSafeArea()

        VStack(spacing: 40) {
          Spacer()

          // アプリタイトル
          VStack(spacing: 16) {
            Text("MySudoku")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(.primary)

            Text("ナンプレ")
              .font(.title2)
              .foregroundColor(.secondary)
          }

          Spacer()

          // メインボタン群
          VStack(spacing: 20) {
            Button(action: {
              viewModel.startNewGame()
            }) {
              Text("新しいゲーム")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(12)
            }

            Button(action: {
              viewModel.resumeGame()
            }) {
              Text("ゲームを再開")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                )
                .cornerRadius(12)
            }

            NavigationLink(destination: Text("統計画面")) {
              Text("統計")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }.disabled(true)

            if viewModel.isAdmin {
              NavigationLink(destination: SettingsView()) {
                Text("設定")
                  .font(.title3)
                  .fontWeight(.medium)
                  .foregroundColor(.primary)
                  .frame(maxWidth: .infinity)
                  .frame(height: 50)
                  .background(Color.orange.opacity(0.2))
                  .cornerRadius(12)
              }
            }
            if viewModel.isAuthenticated {
              VStack(spacing: 12) {
                if let user = viewModel.currentUser {
                  Text("ログイン中: \(user.email)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Button(action: {
                  viewModel.logout()
                }) {
                  Text("ログアウト")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
                }
              }
            } else {
              Button(action: {
                viewModel.showLogin()
              }) {
                Text("ログイン")
                  .font(.title3)
                  .fontWeight(.medium)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .frame(height: 50)
                  .background(Color.green)
                  .cornerRadius(12)
              }
            }
          }
          .padding(.horizontal, 40)

          Spacer()
        }
      }
      .navigationTitle("")
      .navigationBarHidden(true)
      .sheet(isPresented: $viewModel.showingPuzzleList) {
        PuzzleListView(viewModel: viewModel)
      }
      .sheet(isPresented: $viewModel.showingLogin) {
        LoginView()
      }
      .fullScreenCover(isPresented: $viewModel.isGameStarted) {
        GameBoardView(selectedPuzzle: viewModel.selectedPuzzle)
          .navigationBarBackButtonHidden()
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button("戻る") {
                viewModel.isGameStarted = false
              }
            }
          }
      }
    }
  }
}

#Preview {
  HomeView()
}
