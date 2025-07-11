import Foundation

struct AuthResponse: Codable {
  let accessToken: String
  let refreshToken: String
  let user: User
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case user
  }
}

struct User: Codable {
  let id: String
  let email: String
  let emailConfirmed: Bool
  
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
  
  @Published var currentUser: User?
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
      "password": password
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
      let decoder = JSONDecoder()
      let authResponse = try decoder.decode(AuthResponse.self, from: data)
      
      await MainActor.run {
        self.currentUser = authResponse.user
        self.isAuthenticated = true
      }
      
      UserDefaults.standard.set(authResponse.accessToken, forKey: "access_token")
      UserDefaults.standard.set(authResponse.refreshToken, forKey: "refresh_token")
    } else {
      let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let errorMessage = errorData?["error_description"] as? String ?? "サインアップに失敗しました"
      throw AuthError.authenticationFailed(errorMessage)
    }
  }
  
  func signIn(email: String, password: String) async throws {
    guard let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=password") else {
      throw AuthError.invalidURL
    }
    
    let requestBody = [
      "email": email,
      "password": password
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
      let decoder = JSONDecoder()
      let authResponse = try decoder.decode(AuthResponse.self, from: data)
      
      await MainActor.run {
        self.currentUser = authResponse.user
        self.isAuthenticated = true
      }
      
      UserDefaults.standard.set(authResponse.accessToken, forKey: "access_token")
      UserDefaults.standard.set(authResponse.refreshToken, forKey: "refresh_token")
    } else {
      let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let errorMessage = errorData?["error_description"] as? String ?? "ログインに失敗しました"
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
        let user = try decoder.decode(User.self, from: data)
        
        await MainActor.run {
          self.currentUser = user
          self.isAuthenticated = true
        }
      }
    } catch {
      await signOut()
    }
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