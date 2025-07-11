import Foundation

struct AuthResponse: Codable {
  let accessToken: String?
  let refreshToken: String?
  let user: AppUser

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case user
  }
}

struct SignUpResponse: Codable {
  let user: AppUser
  let session: Session?

  struct Session: Codable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case refreshToken = "refresh_token"
    }
  }
}

struct AppUser: Codable {
  let id: String
  let email: String
  let emailConfirmed: Bool
  var isAdmin: Bool = false

  enum CodingKeys: String, CodingKey {
    case id
    case email
    case emailConfirmed = "email_confirmed_at"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    email = try container.decode(String.self, forKey: .email)
    emailConfirmed = try container.decodeIfPresent(String.self, forKey: .emailConfirmed) != nil
  }
}

class AuthService {
  static let shared = AuthService()

  private let baseURL: String
  private let apiKey: String
  private let session: URLSession

  @Published var currentUser: AppUser?
  @Published var isAuthenticated = false

  private init() {
    self.baseURL = Config.supabaseURL
    self.apiKey = Config.supabaseAnonKey

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    self.session = URLSession(configuration: config)
  }

  func signUp(email: String, password: String) async throws {
    guard let url = URL(string: "\(baseURL)/auth/v1/signup") else {
      throw AuthError.invalidURL
    }

    let requestBody = [
      "email": email,
      "password": password,
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
      throw AuthError.encodingError
    }

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AuthError.networkError
    }

    print("SignUp HTTP Status Code: \(httpResponse.statusCode)")
    print("SignUp Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")

    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
      // データが空でない場合のみデコードを試行
      if !data.isEmpty {
        let decoder = JSONDecoder()
        do {
          let signUpResponse = try decoder.decode(SignUpResponse.self, from: data)

          await MainActor.run {
            self.currentUser = signUpResponse.user
            // sessionがある場合（自動ログイン）のみ認証状態を更新
            if let session = signUpResponse.session {
              self.isAuthenticated = true
              UserDefaults.standard.set(session.accessToken, forKey: "access_token")
              UserDefaults.standard.set(session.refreshToken, forKey: "refresh_token")
            } else {
              // メール確認が必要な場合
              self.isAuthenticated = false
            }
          }
        } catch {
          print("SignUp decode error: \(error)")
          // デコードエラーでも成功とみなす（メール確認待ちの可能性）
          throw AuthError.authenticationFailed("アカウントが作成されました。確認メールをご確認ください。")
        }
      } else {
        // 空のレスポンスでも成功とみなす
        throw AuthError.authenticationFailed("アカウントが作成されました。確認メールをご確認ください。")
      }
    } else {
      let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let errorMessage =
        errorData?["error_description"] as? String ?? errorData?["message"] as? String
        ?? "サインアップに失敗しました（HTTP \(httpResponse.statusCode)）"
      throw AuthError.authenticationFailed(errorMessage)
    }
  }

  func signIn(email: String, password: String) async throws {
    guard let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=password") else {
      throw AuthError.invalidURL
    }

    let requestBody = [
      "email": email,
      "password": password,
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
      throw AuthError.encodingError
    }

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AuthError.networkError
    }

    if httpResponse.statusCode == 200 {
      guard !data.isEmpty else {
        throw AuthError.authenticationFailed("ログインレスポンスが空です")
      }

      let decoder = JSONDecoder()
      let authResponse = try decoder.decode(AuthResponse.self, from: data)

      guard let accessToken = authResponse.accessToken,
        let refreshToken = authResponse.refreshToken
      else {
        throw AuthError.authenticationFailed("認証トークンが取得できませんでした")
      }

      UserDefaults.standard.set(accessToken, forKey: "access_token")
      UserDefaults.standard.set(refreshToken, forKey: "refresh_token")

      // Check if user is admin
      let user = authResponse.user
      let isAdmin = await checkIsAdmin(userId: user.id)

      await MainActor.run {
        var updatedUser = user
        updatedUser.isAdmin = isAdmin
        self.currentUser = updatedUser
        self.isAuthenticated = true
      }
    } else {
      let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let errorMessage =
        errorData?["error_description"] as? String ?? errorData?["message"] as? String
        ?? "ログインに失敗しました（HTTP \(httpResponse.statusCode)）"
      throw AuthError.authenticationFailed(errorMessage)
    }
  }

  func signOut() async {
    await MainActor.run {
      self.currentUser = nil
      self.isAuthenticated = false
    }

    UserDefaults.standard.removeObject(forKey: "access_token")
    UserDefaults.standard.removeObject(forKey: "refresh_token")
  }

  func checkAuthStatus() async {
    guard let token = UserDefaults.standard.string(forKey: "access_token") else {
      return
    }

    guard let url = URL(string: "\(baseURL)/auth/v1/user") else {
      return
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(apiKey, forHTTPHeaderField: "apikey")

    do {
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        return
      }

      if httpResponse.statusCode == 200 {
        let decoder = JSONDecoder()
        var user = try decoder.decode(AppUser.self, from: data)

        // Check if user is admin
        let isAdmin = await checkIsAdmin(userId: user.id)
        user.isAdmin = isAdmin

        let updatedUser = user

        await MainActor.run {
          self.currentUser = updatedUser
          self.isAuthenticated = true
        }
      }
    } catch {
      await signOut()
    }
  }

  func checkIsAdmin(userId: String) async -> Bool {
    guard let url = URL(string: "\(baseURL)/rest/v1/admin_users?user_id=eq.\(userId)") else {
      return false
    }

    var request = URLRequest(url: url)
    request.setValue(
      "Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")",
      forHTTPHeaderField: "Authorization")
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        return false
      }

      if httpResponse.statusCode == 200 {
        // If we get any records back, the user is an admin
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
          return !jsonArray.isEmpty
        }
      }
    } catch {
      print("Error checking admin status: \(error)")
    }

    return false
  }
}

enum AuthError: Error, LocalizedError {
  case invalidURL
  case networkError
  case encodingError
  case authenticationFailed(String)

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "無効なURLです"
    case .networkError:
      return "ネットワークエラーが発生しました"
    case .encodingError:
      return "データの変換に失敗しました"
    case .authenticationFailed(let message):
      return message
    }
  }
}
