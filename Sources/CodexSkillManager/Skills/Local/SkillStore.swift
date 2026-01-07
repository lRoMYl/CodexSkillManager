import Foundation
import Observation

@MainActor
@Observable final class SkillStore {
    enum ListState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum DetailState: Equatable {
        case idle
        case loading
        case loaded
        case missing
        case failed(String)
    }

    var skills: [Skill] = []
    var listState: ListState = .idle
    var detailState: DetailState = .idle
    var referenceState: DetailState = .idle
    var selectedSkillID: Skill.ID?
    var selectedMarkdown: String = ""
    var selectedReferenceID: SkillReference.ID?
    var selectedReferenceMarkdown: String = ""

    var selectedSkill: Skill? {
        skills.first { $0.id == selectedSkillID }
    }

    var selectedReference: SkillReference? {
        guard let selectedSkill, let selectedReferenceID else { return nil }
        return selectedSkill.references.first { $0.id == selectedReferenceID }
    }

    func loadSkills() async {
        listState = .loading
        detailState = .idle
        referenceState = .idle

        let baseURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/skills/public")

        do {
            let items = try FileManager.default.contentsOfDirectory(
                at: baseURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            let skills = items.compactMap { url -> Skill? in
                let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
                guard values?.isDirectory == true else { return nil }

                let name = url.lastPathComponent
                let skillFileURL = url.appendingPathComponent("SKILL.md")
                let hasSkillFile = FileManager.default.fileExists(atPath: skillFileURL.path)

                guard hasSkillFile else { return nil }

                let markdown = (try? String(contentsOf: skillFileURL, encoding: .utf8)) ?? ""
                let metadata = parseMetadata(from: markdown)

                let references = referenceFiles(in: url.appendingPathComponent("references"))
                let referencesCount = references.count
                let assetsCount = countEntries(in: url.appendingPathComponent("assets"))
                let scriptsCount = countEntries(in: url.appendingPathComponent("scripts"))
                let templatesCount = countEntries(in: url.appendingPathComponent("templates"))

                return Skill(
                    id: name,
                    name: name,
                    displayName: formatTitle(metadata.name ?? name),
                    description: metadata.description ?? "No description available.",
                    folderURL: url,
                    skillMarkdownURL: skillFileURL,
                    references: references,
                    stats: SkillStats(
                        references: referencesCount,
                        assets: assetsCount,
                        scripts: scriptsCount,
                        templates: templatesCount
                    )
                )
            }

            self.skills = skills.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            listState = .loaded
            if let selectedSkillID,
               self.skills.contains(where: { $0.id == selectedSkillID }) == false {
                self.selectedSkillID = self.skills.first?.id
            } else if selectedSkillID == nil {
                selectedSkillID = self.skills.first?.id
            }

            await loadSelectedSkill()
        } catch {
            listState = .failed(error.localizedDescription)
        }
    }

    func loadSelectedSkill() async {
        guard let selectedSkill else {
            detailState = .idle
            selectedMarkdown = ""
            referenceState = .idle
            selectedReferenceID = nil
            selectedReferenceMarkdown = ""
            return
        }

        let skillURL = selectedSkill.skillMarkdownURL

        detailState = .loading
        referenceState = .idle
        selectedReferenceID = nil
        selectedReferenceMarkdown = ""

        do {
            let raw = try String(contentsOf: skillURL, encoding: .utf8)
            selectedMarkdown = stripFrontmatter(from: raw)
            detailState = .loaded
        } catch {
            detailState = .failed(error.localizedDescription)
            selectedMarkdown = ""
        }
    }

    func selectReference(_ reference: SkillReference) async {
        selectedReferenceID = reference.id
        await loadSelectedReference()
    }

    func loadSelectedReference() async {
        guard let selectedReference else {
            referenceState = .idle
            selectedReferenceMarkdown = ""
            return
        }

        referenceState = .loading

        do {
            let raw = try String(contentsOf: selectedReference.url, encoding: .utf8)
            selectedReferenceMarkdown = stripFrontmatter(from: raw)
            referenceState = .loaded
        } catch {
            referenceState = .failed(error.localizedDescription)
            selectedReferenceMarkdown = ""
        }
    }

    func deleteSkills(ids: [Skill.ID]) async {
        let fileManager = FileManager.default
        for id in ids {
            guard let skill = skills.first(where: { $0.id == id }) else { continue }
            try? fileManager.removeItem(at: skill.folderURL)
        }
        await loadSkills()
    }
}
