import Foundation

struct Cell: Identifiable, Codable {
  let id: UUID
  var value: Int?
  var given: Int?
  var pencilMarks: Set<Int> = []

  var isGiven: Bool {
    return given != nil
  }

  var isEmpty: Bool {
    return value == nil && given == nil
  }

  var displayValue: Int? {
    return given ?? value
  }

  init(value: Int? = nil, given: Int? = nil, pencilMarks: Set<Int> = []) {
    self.id = UUID()
    self.value = value
    self.given = given
    self.pencilMarks = pencilMarks
  }
}
