import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
  @Published var isGameStarted = false
  @Published var showingDifficultySelection = false

  enum Difficulty: String, CaseIterable {
    case easy = "簡単"
    case medium = "普通"
    case hard = "難しい"
  }

  @Published var selectedDifficulty: Difficulty = .medium

  func startNewGame() {
    showingDifficultySelection = true
  }

  func startGameWithDifficulty(_ difficulty: Difficulty) {
    selectedDifficulty = difficulty
    showingDifficultySelection = false
    isGameStarted = true
  }

  func resumeGame() {
    isGameStarted = true
  }

}
