import SwiftUI

struct RemoteSkillRowView: View {
    let skill: RemoteSkill

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(skill.displayName)
                .font(.headline)
                .foregroundStyle(.primary)

            if let summary = skill.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let version = skill.version {
                Text("Version \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
