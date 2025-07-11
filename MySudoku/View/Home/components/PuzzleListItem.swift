import SwiftUI

struct PuzzleListItem: View {
  let puzzle: SupabaseResponse
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("パズル ID: \(puzzle.id)")
            .font(.headline)
            .foregroundColor(.primary)

          Spacer()

          Text(puzzle.difficulty.description)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(getDifficultyColor(puzzle.difficulty))
            .foregroundColor(.white)
            .cornerRadius(12)
        }

        if let createdAt = puzzle.createdAt {
          Text("作成日: \(createdAt, formatter: dateFormatter)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding(.vertical, 4)
    }
    .buttonStyle(PlainButtonStyle())
  }

  private func getDifficultyColor(_ difficulty: Int) -> Color {
    if difficulty < 1000 {
      return .green
    } else if difficulty < 2000 {
      return .orange
    } else if difficulty < 3000 {
      return .red
    } else {
      return .purple
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }
}
