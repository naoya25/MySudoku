import Foundation

struct Move: Codable {
    let cellID: UUID
    let previousValue: Int?
    let newValue: Int?
    let previousMarks: Set<Int>
    let newMarks: Set<Int>
    let timestamp: Date
    
    init(cellID: UUID, previousValue: Int?, newValue: Int?, previousMarks: Set<Int>, newMarks: Set<Int>) {
        self.cellID = cellID
        self.previousValue = previousValue
        self.newValue = newValue
        self.previousMarks = previousMarks
        self.newMarks = newMarks
        self.timestamp = Date()
    }
}