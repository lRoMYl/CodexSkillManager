import SwiftUI

struct SkillRowView: View {
    let skill: Skill

    private var visibleTags: [String] {
        Array(skill.tagLabels.prefix(3))
    }

    private var overflowCount: Int {
        max(skill.tagLabels.count - visibleTags.count, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(skill.displayName)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(skill.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !skill.tagLabels.isEmpty {
                HStack(spacing: 6) {
                    ForEach(visibleTags, id: \.self) { tag in
                        TagView(text: tag)
                    }
                    if overflowCount > 0 {
                        TagView(text: "+\(overflowCount) more")
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
