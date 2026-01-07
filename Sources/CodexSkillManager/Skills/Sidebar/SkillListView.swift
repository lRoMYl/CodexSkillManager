import SwiftUI

struct SkillListView: View {
    @Environment(SkillStore.self) private var store

    let localSkills: [Skill]
    let remoteSkills: [RemoteSkill]
    
    @Binding var source: SkillSource
    @Binding var localSelection: Skill.ID?
    @Binding var remoteSelection: RemoteSkill.ID?

    var body: some View {
        List(selection: source == .local ? $localSelection : $remoteSelection) {
            Section {
                if source == .local {
                    ForEach(localSkills) { skill in
                        SkillRowView(skill: skill)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await store.deleteSkills(ids: [skill.id]) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete { offsets in
                        let ids = offsets
                            .filter { localSkills.indices.contains($0) }
                            .map { localSkills[$0].id }
                        Task { await store.deleteSkills(ids: ids) }
                    }
                } else {
                    if remoteSkills.isEmpty {
                        Text("Search Clawdhub to see skills.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(remoteSkills) { skill in
                            RemoteSkillRowView(skill: skill)
                        }
                    }
                }
            } header: {
                SidebarHeaderView(
                    skillCount: source == .local ? localSkills.count : remoteSkills.count,
                    source: $source
                )
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await store.loadSkills() }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
                .disabled(source != .local)
            }
        }
    }
}
