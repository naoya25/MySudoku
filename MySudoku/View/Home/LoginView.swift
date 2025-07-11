import SwiftUI

struct LoginView: View {
  @StateObject private var viewModel = LoginViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      VStack(spacing: 32) {
        Spacer()

        VStack(spacing: 16) {
          Text("ログイン")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          Text("メールアドレスでログイン")
            .font(.body)
            .foregroundColor(.secondary)
        }

        VStack(spacing: 16) {
          TextField("メールアドレス", text: $viewModel.email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)

          SecureField("パスワード", text: $viewModel.password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 32)

        VStack(spacing: 16) {
          Button(action: {
            Task {
              await viewModel.signIn()
            }
          }) {
            HStack {
              if viewModel.isLoading {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .scaleEffect(0.8)
              }
              Text("ログイン")
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(12)
          }
          .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)

          Button(action: {
            Task {
              await viewModel.signUp()
            }
          }) {
            HStack {
              if viewModel.isSigningUp {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                  .scaleEffect(0.8)
              }
              Text("アカウント作成")
                .fontWeight(.medium)
            }
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
          .disabled(viewModel.isSigningUp || viewModel.email.isEmpty || viewModel.password.isEmpty)
        }
        .padding(.horizontal, 32)

        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .foregroundColor(.red)
            .font(.caption)
            .padding(.horizontal, 32)
        }

        Spacer()
      }
      .navigationTitle("")
      .navigationBarHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("キャンセル") {
            dismiss()
          }
        }
      }
      .alert("成功", isPresented: $viewModel.showingSuccess) {
        Button("OK") {
          dismiss()
        }
      } message: {
        Text(viewModel.successMessage ?? "")
      }
    }
  }
}

#Preview {
  LoginView()
}
