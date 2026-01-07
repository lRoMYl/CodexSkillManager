import SwiftUI

struct SidebarHeaderView: View {
    let skillCount: Int
    @Binding var source: SkillSource

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Picker("Source", selection: $source) {
                    ForEach(SkillSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(source == .local ? "Codex Skills" : "Clawdhub")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Text("\(skillCount) skills")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .textCase(nil)
    }
}
