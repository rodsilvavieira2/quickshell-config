# Quickshell Agent Guidelines

This document provides essential information for automated agents working in this repository.

## 1. Project Context
- **Framework:** [Quickshell](https://quickshell.org/) (Qt6/QML), a modular Wayland shell optimized for Hyprland.
- **Language:** QML 2.15+ with embedded JavaScript (Qt6 engine).
- **Architecture:** 12 independent modules, each running as a standalone daemon (entrypoint: `shell.qml`).
- **Standard Layout:** `shell.qml` (entry), `common/` (singletons), `services/` (backend/data), `modules/` (UI), `assets/` (static).
- **Communication:** Modules interact via IPC using `IpcHandler`.

## 2. Running & Testing (Single Module/File)
No formal build or test suite exists. Use these commands to run and verify changes:
- **Run a Module:** `quickshell -c <module>` (e.g., `qs -c waybar`).
- **Sandbox a Component (Single Test):** `quickshell -p path/to/Component.qml &`.
- **IPC Triggers:** `quickshell ipc -c <module> call <module> <method>` (e.g., `toggle`, `open`, `close`).
- **Live Debug Logs:**
  ```bash
  quickshell -c <module> > debug.log 2>&1 &
  # Follow the latest log generated in /run/user/1000/quickshell/by-id/
  tail -f /run/user/1000/quickshell/by-id/$(ls -t /run/user/1000/quickshell/by-id | head -n 1)/log.qslog
  ```

## 3. Code Style & Standards
### Pragmas & Imports
Pragmas must appear at the very top of the file before any imports.
```qml
//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
```
Import order (blank line between groups):
1.  **Qt:** `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `QtQuick.Shapes`, `QtQuick.Effects`.
2.  **Quickshell:** `Quickshell`, `Quickshell.Io`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `Quickshell.Services.*`.
3.  **Local:** Relative paths (e.g., `import "./common"`).

### Naming Conventions
- **QML Files:** `PascalCase.qml`.
- **IDs:** `root` for reusable roots; `shellRoot` for `ShellRoot`; `camelCase` for others (descriptive, no `item1`).
- **Properties/Functions/Signals:** `camelCase`.
- **IPC Targets:** All-lowercase module name (e.g., `"notifications"`).

### Formatting & Structure
- **Indentation:** 4 spaces, no tabs.
- **Property Order:** `id`, declarations, signal handlers, core props (`width`, `height`), anchors, children, states.
- **Colors:** Hex (`#1e1e2e`) or `Qt.rgba()`. No CSS-style `rgba()` strings.
- **Fonts:** `"JetBrainsMono Nerd Font"`. Inline Nerd Font glyphs directly in `Text`.
### Theming & Singletons
- Use `Appearance.colors.*` and `Appearance.m3colors.*` (Catppuccin Mocha Dark theme).
- Shared config/appearance live in `common/` with a `qmldir`.
- Declare singletons with:
  ```qml
  pragma Singleton
  pragma ComponentBehavior: Bound
  import Quickshell
  Singleton { id: root }
  ```
- Register in `qmldir`: `singleton GlobalStates 1.0 GlobalStates.qml`.

### Types & Data
- **Strong Typing:** Use `bool`, `int`, `real`, `string`, `color`.
- **Lists:** Prefer `property list<T>` over `property var` where possible.
- **Delegates:** Use `required` for `modelData` and `index` to prevent undefined access.
- **Inline Types:** Use QML 6 `component Name: Base { ... }` for reusable sub-types within a file.

## 4. JavaScript & Logic
- **Practices:** Use `const`/`let` (no `var`), strict equality (`===`), optional chaining (`?.`), and nullish coalescing (`??`).
- **Array Methods:** `.filter()`, `.map()`, `.find()`, `.reduce()`.
- **Async Commands:** Use `Quickshell.execDetached([...])` for fire-and-forget.
- **Deferred Execution:** Use `Qt.callLater(fn)` for same-event-loop turn execution.
- **External Processes:** Use `Process` + `StdioCollector` or `SplitParser` for line-by-line output.
  ```qml
  Process { id: p; command: ["bash", "-c", "cmd"]; onStreamFinished: { /* process text */ } }
  ```

## 5. Error Handling & Safety
- **Guard Rails:** Check object existence before calling methods. Wrap external JSON parsing in `try/catch`.
- **Dynamic Targets:** Ensure `Connections { target: x }` handles `x` being `null` or `undefined`.
- **Hyprland Safety:** Use signal-driven updates via `Connections` rather than one-shot reads in `Component.onCompleted`.
- **Shell Escaping:** Use `StringUtils.shellSingleQuoteEscape()` for input-derived shell strings.

## 6. Layout & Window Behavior
- **Overlays:** Use `PanelWindow` with `WlrLayer.Overlay` and `WlrKeyboardFocus.Exclusive`.
- **Interactions:** Always provide a background `MouseArea` to close panels and an inner one to consume clicks.
- **Multi-Screen:** Target `Quickshell.screens` based on `Hyprland.focusedMonitor`.

## 7. Cursor & Copilot Rules
- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot rules found in `.github/copilot-instructions.md`.

## 8. Quick References
- **Entrypoints:** `applauncher/shell.qml`, `waybar/shell.qml`, `overview/shell.qml`, `dashboard/shell.qml`, etc.
- **Singletons:** `<module>/common/Appearance.qml`, `<module>/common/Config.qml`.
- **Theming Palette (Mocha):** Base `#1e1e2e`, Text `#cdd6f4`, Blue `#89b4fa`, Surface0 `#313244`.
- **Search Services:** `search/services/{AppSearch,WebSearch,EmojiSearch,ClipboardSearch}.qml`.
- **More Docs:** `GEMINI.md`, `overview/README.md`, `notifications/README.md`.
