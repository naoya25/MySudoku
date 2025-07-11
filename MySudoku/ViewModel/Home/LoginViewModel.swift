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
      successMessage = "アカウントが作成されました。"
      showingSuccess = true
      // 成功後は入力フィールドをクリア
      email = ""
      password = ""
    } catch {
      if let authError = error as? AuthError,
        case .authenticationFailed(let message) = authError,
        message.contains("アカウントが作成されました")
      {
        // サインアップ成功メッセージの場合は成功として扱う
        successMessage = message
        showingSuccess = true
        email = ""
        password = ""
      } else {
        errorMessage = error.localizedDescription
      }
    }

    isSigningUp = false
  }
}
