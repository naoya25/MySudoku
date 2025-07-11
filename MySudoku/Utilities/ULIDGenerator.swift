import Foundation

/// ULID (Universally Unique Lexicographically Sortable Identifier) Generator
/// ULIDは時間順にソート可能なユニークIDを生成します
struct ULIDGenerator {
  private static let encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  private static let encodingLength = 32

  /// 現在の時刻を基にULIDを生成
  static func generate() -> String {
    return generate(timestamp: Date())
  }

  /// 指定された時刻を基にULIDを生成
  static func generate(timestamp: Date) -> String {
    let timestampMs = Int64(timestamp.timeIntervalSince1970 * 1000)
    let timestampPart = encodeTimestamp(timestampMs)
    let randomPart = encodeRandom()

    return timestampPart + randomPart
  }

  /// タイムスタンプ部分をエンコード (10文字)
  private static func encodeTimestamp(_ timestamp: Int64) -> String {
    var value = timestamp
    var result = ""

    for _ in 0..<10 {
      let index = Int(value % Int64(encodingLength))
      result = String(encoding[encoding.index(encoding.startIndex, offsetBy: index)]) + result
      value /= Int64(encodingLength)
    }

    return result
  }

  /// ランダム部分をエンコード (16文字)
  private static func encodeRandom() -> String {
    var result = ""

    for _ in 0..<16 {
      let randomIndex = Int.random(in: 0..<encodingLength)
      result += String(encoding[encoding.index(encoding.startIndex, offsetBy: randomIndex)])
    }

    return result
  }
}

/// グローバル関数としてのULID生成
func generateULID() -> String {
  return ULIDGenerator.generate()
}

/// 指定された時刻でのULID生成
func generateULID(timestamp: Date) -> String {
  return ULIDGenerator.generate(timestamp: timestamp)
}

/// ULIDの検証
func isValidULID(_ ulid: String) -> Bool {
  // 長さが26文字であることを確認
  guard ulid.count == 26 else { return false }

  // 使用可能な文字のみで構成されていることを確認
  let validCharacters = Set("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
  return Set(ulid.uppercased()).isSubset(of: validCharacters)
}

/// ULIDからタイムスタンプを抽出
func extractTimestamp(from ulid: String) -> Date? {
  guard isValidULID(ulid) else { return nil }

  let timestampPart = String(ulid.prefix(10))
  let encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

  var timestamp: Int64 = 0
  var multiplier: Int64 = 1

  for char in timestampPart.reversed() {
    guard let index = encoding.firstIndex(of: char) else { return nil }
    let value = encoding.distance(from: encoding.startIndex, to: index)
    timestamp += Int64(value) * multiplier
    multiplier *= 32
  }

  return Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
}
