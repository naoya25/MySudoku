import SwiftUI

struct SolutionShortcutSheet: View {
  @Binding var isPresented: Bool
  let onSelectStep: (SolutionStep) -> Void

  enum SolutionStep: CaseIterable {
    case fillObviousCells
    case fillAllNotes
    case nakedSingle
    case hiddenSingle
    case pointingPair

    var title: String {
      switch self {
      case .fillObviousCells:
        return "自明なマスを埋める"
      case .fillAllNotes:
        return "全候補をメモする"
      case .nakedSingle:
        return "単一候補法"
      case .hiddenSingle:
        return "隠れ単一候補法"
      case .pointingPair:
        return "ポイントペア法"
      }
    }

    var description: String {
      switch self {
      case .fillObviousCells:
        return "行・列・ブロックで候補が1つに絞られるマスを自動的に埋めます"
      case .fillAllNotes:
        return "空いているマスに入る可能性のある数字を全てメモとして記入します"
      case .nakedSingle:
        return "候補が1つしかないマスに数字を確定します"
      case .hiddenSingle:
        return "行・列・ブロック内で、ある数字が1つのマスにしか入らない場合に確定します"
      case .pointingPair:
        return "ブロック内で候補が同じ行・列にしかない場合、他のブロックから候補を除外します"
      }
    }

    var icon: String {
      switch self {
      case .fillObviousCells:
        return "1.square.fill"
      case .fillAllNotes:
        return "note.text"
      case .nakedSingle:
        return "square.and.pencil"
      case .hiddenSingle:
        return "eye.slash"
      case .pointingPair:
        return "arrow.left.and.right"
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      dragIndicator

      header

      ScrollView {
        VStack(spacing: 12) {
          ForEach(SolutionStep.allCases, id: \.self) { step in
            stepButton(for: step)
          }
        }
        .padding(20)
      }
    }
    .background(Color(.systemBackground))
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }

  private var dragIndicator: some View {
    RoundedRectangle(cornerRadius: 3)
      .fill(Color(.systemGray3))
      .frame(width: 40, height: 5)
      .padding(.top, 8)
      .padding(.bottom, 12)
  }

  private var header: some View {
    HStack {
      Text("解法ショートカット")
        .font(.headline)

      Spacer()

      Button("閉じる") {
        isPresented = false
      }
      .font(.body)
      .foregroundColor(.blue)
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 12)
  }

  private func stepButton(for step: SolutionStep) -> some View {
    Button(action: {
      onSelectStep(step)
      isPresented = false
    }) {
      HStack(spacing: 16) {
        Image(systemName: step.icon)
          .font(.title2)
          .frame(width: 40, height: 40)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(8)

        VStack(alignment: .leading, spacing: 4) {
          Text(step.title)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.primary)

          Text(step.description)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(16)
      .background(Color(.secondarySystemBackground))
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
