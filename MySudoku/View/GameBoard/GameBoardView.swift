import SwiftUI

struct GameBoardView: View {
  @StateObject private var viewModel = GameBoardViewModel()

  var body: some View {
    VStack {
      switch viewModel.gameState {
      case .error:
        errorView
      case .playing:
        gameView
      case .paused:
        pausedView
      case .completed:
        completedView
      }
    }
    .navigationTitle("MySudoku")
    .onAppear {
      viewModel.startNewGame()
    }
  }

  private var gameView: some View {
    VStack(spacing: 0) {
      // 上部: タイマーと間違い数カウント
      StatusBar(
        elapsedTime: "00:00",
        errorCount: 0,
        maxErrors: 3,
        isPaused: viewModel.gameState == .paused,
        onPauseToggle: {
          viewModel.togglePause()
        }
      )

      Spacer()

      // 中央: 9x9盤面
      SudokuGrid(
        board: viewModel.board,
        selectedPosition: viewModel.selectedPosition,
        validationResult: viewModel.getValidationResult(),
        onCellTap: { position in
          viewModel.selectCell(at: position)
        }
      )
      .padding(.horizontal, 20)

      Spacer()

      // 下部: 設定ボタン群
      ControlButtons(
        isNoteMode: viewModel.isNoteMode,
        onUndo: {
          // TODO: Undo functionality
        },
        onToggleNoteMode: {
          viewModel.toggleNoteMode()
        },
        onClear: {
          viewModel.clearCell()
        }
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 10)

      // 最下部: 数字ボタン
      NumberPad(onNumberTap: { number in
        viewModel.enterNumber(number)
      })
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .background(Color(.systemBackground))
  }

  private var pausedView: some View {
    VStack(spacing: 30) {
      Image(systemName: "pause.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(.blue)

      Text("一時停止中")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("ゲームを続けるには再生ボタンをタップしてください")
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      Button("再開") {
        viewModel.togglePause()
      }
      .font(.title2)
      .foregroundColor(.white)
      .frame(width: 150, height: 50)
      .background(Color.blue)
      .cornerRadius(10)
    }
    .padding()
  }

  private var completedView: some View {
    VStack(spacing: 30) {
      Text("おめでとうございます！")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("パズルを完成させました")
        .font(.title2)

      Button("新しいゲーム") {
        viewModel.startNewGame()
      }
      .font(.title2)
      .foregroundColor(.white)
      .frame(width: 200, height: 50)
      .background(Color.green)
      .cornerRadius(10)
    }
  }

  private var errorView: some View {
    VStack(spacing: 20) {
      Text("エラーが発生しました")
        .font(.largeTitle)
        .fontWeight(.bold)

      Button("リトライ") {
        viewModel.startNewGame()
      }
      .font(.title2)
      .foregroundColor(.white)
      .frame(width: 150, height: 50)
      .background(Color.red)
      .cornerRadius(10)
    }
  }
}

#Preview {
  GameBoardView()
}
