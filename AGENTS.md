# Quickshell Agent Guidelines

This file describes how to work in this repository as an automated coding agent.

## 1. Project Context
- Framework: Quickshell (Qt/QML shell for Wayland, optimized for Hyprland)
- Language: QML with embedded JavaScript (Qt6 engine)
- Structure: independent configurations in top-level folders (applauncher/, controlcenter/, overview/, powermenu/, search/)
- Each configuration must have a root `shell.qml` and runs as its own daemon process
- Configs communicate via IPC using `IpcHandler`

## 2. Build, Lint, Test
- No build step or automated lint/test suite is defined in this repo
- Run a configuration (example):
  ```bash
  quickshell -c applauncher &
  # If you use the qs alias:
  qs -c applauncher &
  ```
- IPC actions (toggle/open/close example):
  ```bash
  quickshell ipc -c applauncher call applauncher toggle
  quickshell ipc -c applauncher call applauncher open
  quickshell ipc -c applauncher call applauncher close
  ```
- Run a single QML file (sandbox):
  ```bash
  quickshell -p path/to/TestComponent.qml &
  ```
- Debug logs:
  ```bash
  quickshell -c applauncher > debug.log 2>&1 &
  tail -f debug.log
  ```
- Persistent log (most recent):
  ```bash
  cat /run/user/1000/quickshell/by-id/$(ls -t /run/user/1000/quickshell/by-id | head -n 1)/log.qslog
  ```

## 3. Imports and Pragmas
- Keep pragmas at the top of the file, before imports
- Typical pragmas:
  ```qml
  //@ pragma UseQApplication
  //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
  //@ pragma IconTheme "Suru++"
  //@ pragma Env QS_ICON_THEME=Suru++
  ```
- Import order with blank lines between groups:
  - Qt imports first (QtQuick, Controls, Layouts)
  - Quickshell imports second
  - Local relative imports last

## 4. Naming
- QML files are PascalCase, except the entrypoint `shell.qml`
- IDs are camelCase and descriptive (no item1, rect, etc.)
- Properties, functions, and signals use camelCase
- Use `required` properties in delegates for modelData/index

## 5. Formatting and Structure
- Indent with 4 spaces, never tabs
- Property order inside an element:
  1. id
  2. property declarations
  3. signal handlers
  4. core properties (width/height/color/etc.)
  5. anchors and Layout bindings
  6. child elements
  7. states/transitions
- Keep anchors grouped in an `anchors {}` block
- Use hex colors or `Qt.rgba()`; avoid CSS rgba strings
- Keep inline JavaScript small; extract to functions or .js when it grows

## 6. Types and Data
- Use strong property types when known: bool, int, real, string, color
- Use `property var` only for arrays or dynamic objects
- Prefer typed lists for QML properties (example: `property list<real>`)
- Use `required` properties in delegates to avoid undefined access
- When parsing external data, guard against empty/invalid values

## 7. Singletons and Common Modules
- Shared config and appearance live in `common/` directories
- For singletons use:
  ```qml
  pragma Singleton
  pragma ComponentBehavior: Bound
  ```
- Keep helper functions in `common/functions/` and widgets in `common/widgets/`
- Import singletons via relative paths (example: `import "../common"`)

## 8. JavaScript Practices
- Use `let` and `const`, avoid `var`
- Use strict equality (`===`/`!==`)
- Use optional chaining and nullish coalescing for nested data
- Avoid assuming index 0 exists for dynamic lists
- Prefer arrow functions for short callbacks
- Use template strings for composed commands or labels

## 9. Error Handling and Safety
- Always check objects exist before calling methods
- Guard external command output before parsing or JSON decoding
- Use `Connections` with a clear target; handle target being undefined
- For dynamic data (Hyprland, DesktopEntries), prefer signal-driven updates over one-off reads in Component.onCompleted
- When running commands, use `Quickshell.execDetached` or `Process` and handle empty output
- Use `StringUtils.shellSingleQuoteEscape()` for shell commands derived from user input

## 10. IPC and Window Behavior
- Use `IpcHandler` with clear target names per module
- For overlays use `PanelWindow` and set WlrLayershell namespace/layer/keyboardFocus
- Provide a focus catcher and handle Escape to close
- Ensure mouse areas prevent click-through and consume internal clicks

## 11. Lists and Models
- Use `ListView`/`Repeater` with `required` delegate properties
- Keep model computations lightweight; use `Timer` or `Connections` to debounce when needed
- Use `boundsBehavior: Flickable.StopAtBounds` for stable scrolling
- Prefer `ScriptModel` or helper functions for filtered/sorted lists

## 12. Resources and Assets
- Use `Quickshell.iconPath()` for icons with fallbacks
- Use `Quickshell.shellPath()` for local assets and actions
- Avoid hardcoding absolute system paths unless required
- Store assets in `assets/` inside a module when possible

## 13. Theming
- The theme is Catppuccin Mocha Dark; do not introduce random colors
- Core palette:
  - Background: `#1e1e2e`
  - Borders/selected: `#313244`
  - Primary text: `#cdd6f4`
  - Secondary text: `#a6adc8`
  - Overlay/shadow: `#66000000`
- Prefer radius values like 8 or 12 and use spacing for hierarchy
- Use existing `Appearance` objects for fonts, sizes, and animations

## 14. Repo Workflows
- Keep configurations modular; do not merge unrelated tools
- Restart the specific config after changes to validate
- Use IPC to open/close UI for quick verification
- Expect asynchronous population of Hyprland data; handle race conditions with care
- Avoid expensive work in bindings that rerun every frame

## 15. Cursor/Copilot Rules
- No Cursor rules found in `.cursor/rules/` or `.cursorrules`
- No Copilot rules found in `.github/copilot-instructions.md`

## 16. Quick References
- Module entrypoints: `applauncher/shell.qml`, `controlcenter/shell.qml`, `overview/shell.qml`, `powermenu/shell.qml`, `search/shell.qml`
- Common styles and options live in `overview/common` and `search/common`
- Actions for search live in `search/actions`
- Emoji data lives in `search/assets/emoji.txt`
