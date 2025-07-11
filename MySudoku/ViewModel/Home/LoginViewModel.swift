import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var isLoading = false
  @Published var isSigningUp = false
  @Published var errorMessage: String?
  @Published var successMessage: String?
  @Published var showingSuccess = false

  func signIn() async {
    guard !email.isEmpty && !password.isEmpty else {
      errorMessage = "メールアドレスとパスワードを入力してください"
      return
    }

    isLoading = true
    errorMessage = nil

    do {
      try await AuthService.shared.signIn(email: email, password: password)
      successMessage = "ログインに成功しました"
      showingSuccess = true
    } catch {
      errorMessage = error.localizedDescription
    }

    isLoading = false
  }

  func signUp() async {
    guard !email.isEmpty && !password.isEmpty else {
      errorMessage = "メールアドレスとパスワードを入力してください"
      return
    }

    isSigningUp = true
    errorMessage = nil

    do {
      try await AuthService.shared.signUp(email: email, password: password)
      successMessage = "アカウントが作成されました。確認メールをご確認ください。"
      showingSuccess = true
    } catch {
      errorMessage = error.localizedDescription
    }

    isSigningUp = false
  }
}
