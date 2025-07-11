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

            NavigationLink(destination: Text("設定画面")) {
              Text("設定")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }.disabled(true)
          }
          .padding(.horizontal, 40)

          Spacer()
        }
      }
      .navigationTitle("")
      .navigationBarHidden(true)
      .sheet(isPresented: $viewModel.showingDifficultySelection) {
        DifficultySelectionView(viewModel: viewModel)
      }
      .fullScreenCover(isPresented: $viewModel.isGameStarted) {
        GameBoardView()
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

struct DifficultySelectionView: View {
  @ObservedObject var viewModel: HomeViewModel

  var body: some View {
    NavigationView {
      VStack(spacing: 30) {
        Text("難易度を選択")
          .font(.title2)
          .fontWeight(.bold)
          .padding(.top, 20)

        VStack(spacing: 15) {
          ForEach(HomeViewModel.Difficulty.allCases, id: \.self) { difficulty in
            Button(action: {
              viewModel.startGameWithDifficulty(difficulty)
            }) {
              HStack {
                Text(difficulty.rawValue)
                  .font(.title3)
                  .fontWeight(.medium)
                Spacer()
                if viewModel.selectedDifficulty == difficulty {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                }
              }
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(
                    viewModel.selectedDifficulty == difficulty
                      ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
              )
            }
            .foregroundColor(.primary)
          }
        }
        .padding(.horizontal, 20)

        Spacer()
      }
      .navigationTitle("難易度選択")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("キャンセル") {
            viewModel.showingDifficultySelection = false
          }
        }
      }
    }
  }
}

#Preview {
  HomeView()
}
