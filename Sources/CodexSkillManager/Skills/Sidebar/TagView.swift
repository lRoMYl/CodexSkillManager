import SwiftUI

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(tagColor.opacity(0.18))
            )
    }

    private var tagColor: Color {
        let colors: [Color] = [
            .mint, .teal, .cyan, .blue, .indigo, .green, .orange
        ]
        let index = abs(text.hashValue) % colors.count
        return colors[index]
    }
}
