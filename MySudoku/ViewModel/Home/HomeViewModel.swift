import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
  @Published var isGameStarted = false
  @Published var showingPuzzleList = false
  @Published var puzzles: [SupabaseResponse] = []
  @Published var isLoadingPuzzles = false
  @Published var errorMessage: String?
  @Published var selectedPuzzle: SupabaseResponse?
  @Published var showingLogin = false

  enum Difficulty: String, CaseIterable {
    case easy = "簡単"
    case medium = "普通"
    case hard = "難しい"
  }

  @Published var selectedDifficulty: Difficulty = .medium

  func startNewGame() {
    showingPuzzleList = true
    loadPuzzles()
  }

  func startGameWithDifficulty(_ difficulty: Difficulty) {
    selectedDifficulty = difficulty
    showingPuzzleList = false
    isGameStarted = true
  }

  func startGameWithPuzzle(_ puzzle: SupabaseResponse) {
    selectedPuzzle = puzzle
    showingPuzzleList = false
    isGameStarted = true
  }

  func resumeGame() {
    isGameStarted = true
  }
  
  func showLogin() {
    showingLogin = true
  }

  func loadPuzzles() {
    isLoadingPuzzles = true
    errorMessage = nil

    Task {
      do {
        let fetchedPuzzles = try await SupabaseService.shared.fetchAllPuzzles()
        await MainActor.run {
          self.puzzles = fetchedPuzzles
          self.isLoadingPuzzles = false
        }
      } catch {
        await MainActor.run {
          self.errorMessage = error.localizedDescription
          self.isLoadingPuzzles = false
        }
      }
    }
  }

  func getDifficultyLabel(_ difficulty: Int) -> String {
    switch difficulty {
    case 1:
      return "簡単"
    case 2:
      return "普通"
    case 3:
      return "難しい"
    default:
      return "不明"
    }
  }
}
