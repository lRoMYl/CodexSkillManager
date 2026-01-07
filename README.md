# Codex Skill Manager

![image](image.png)

Codex Skill Manager is a macOS SwiftUI app built with SwiftPM (no Xcode project). It lists your Codex skills and renders each `SKILL.md` with Markdown.

## Features
- Sidebar list of skills from `~/.codex/skills/public`
- Rich detail view with Markdown rendering
- Inline reference preview for `references/*.md`
- Toolbar actions: reload, open skills folder, import (placeholder)

## Requirements
- macOS 14+
- Swift 6.2+

## Build and run
```
swift build
swift run CodexSkillManager
```

## Package a local app
```
./Scripts/compile_and_run.sh
```

## Credits
- Markdown rendering via https://github.com/gonzalezreal/swift-markdown-ui
