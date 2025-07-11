import SwiftUI

struct NumberPad: View {
    let onNumberTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...9, id: \.self) { number in
                Button("\(number)") {
                    onNumberTap(number)
                }
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.gray.opacity(0.1))
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
            }
        }
        .cornerRadius(8)
    }
}