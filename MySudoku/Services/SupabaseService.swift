import Foundation

struct SupabaseResponse: Codable {
  let id: String
  let givenData: String
  let solutionData: String
  let difficulty: Int
  let createdAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case givenData = "given_data"
    case solutionData = "solution_data"
    case difficulty
    case createdAt = "created_at"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    givenData = try container.decode(String.self, forKey: .givenData)
    solutionData = try container.decode(String.self, forKey: .solutionData)
    difficulty = try container.decode(Int.self, forKey: .difficulty)

    if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
      let formatter = ISO8601DateFormatter()
      createdAt = formatter.date(from: dateString)
    } else {
      createdAt = nil
    }
  }
}

class SupabaseService {
  static let shared = SupabaseService()

  private let baseURL: String
  private let apiKey: String
  private let session: URLSession

  private init() {
    self.baseURL = Config.supabaseURL
    self.apiKey = Config.supabaseAnonKey

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    self.session = URLSession(configuration: config)
  }

  func fetchRandomPuzzle() async throws -> Board {
    guard let url = URL(string: "\(baseURL)/rest/v1/sudoku?select=*&order=id&limit=1") else {
      throw SupabaseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw SupabaseError.networkError
      }

      guard httpResponse.statusCode == 200 else {
        throw SupabaseError.httpError(httpResponse.statusCode)
      }

      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let responses = try decoder.decode([SupabaseResponse].self, from: data)

      guard let response = responses.first else {
        throw SupabaseError.noPuzzleFound
      }

      return Board(givenData: response.givenData, solutionData: response.solutionData)
    } catch {
      if error is SupabaseError {
        throw error
      } else {
        throw SupabaseError.decodingError(error)
      }
    }
  }

  func fetchPuzzleByDifficulty(_ difficulty: Int) async throws -> Board {
    guard
      let url = URL(
        string: "\(baseURL)/rest/v1/sudoku?select=*&difficulty=eq.\(difficulty)&order=id&limit=1")
    else {
      throw SupabaseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue(apiKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw SupabaseError.networkError
      }

      guard httpResponse.statusCode == 200 else {
        throw SupabaseError.httpError(httpResponse.statusCode)
      }

      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let responses = try decoder.decode([SupabaseResponse].self, from: data)

      guard let response = responses.first else {
        throw SupabaseError.noPuzzleFound
      }

      return Board(givenData: response.givenData, solutionData: response.solutionData)
    } catch {
      if error is SupabaseError {
        throw error
      } else {
        throw SupabaseError.decodingError(error)
      }
    }
  }
}

enum SupabaseError: Error, LocalizedError {
  case invalidURL
  case networkError
  case noPuzzleFound
  case httpError(Int)
  case decodingError(Error)
  case configurationError

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid Supabase URL"
    case .networkError:
      return "Network connection error"
    case .noPuzzleFound:
      return "No puzzle found"
    case .httpError(let statusCode):
      return "HTTP error: \(statusCode)"
    case .decodingError(let error):
      return "Decoding error: \(error.localizedDescription)"
    case .configurationError:
      return
        "Supabase configuration is missing. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables."
    }
  }
}
