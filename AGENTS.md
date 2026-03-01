# Quickshell Agent Guidelines

This file describes how to work in this repository as an automated coding agent.

## 1. Project Context
- Framework: Quickshell (Qt6/QML), Wayland shell optimized for Hyprland
- Language: QML 2.15+ with embedded JavaScript (Qt6 engine)
- Structure: 12 independent modules, each a standalone daemon with its own `shell.qml`
- Modules: `applauncher`, `audio`, `bluetooth`, `controlcenter`, `dashboard`, `network`, `notifications`, `overview`, `powermenu`, `search`, `wallpaper`, `waybar`
- Standard per-module layout: `shell.qml`, `common/` (singletons), `services/` (backend/data), `modules/` (UI), `assets/` (static data)
- Modules communicate via IPC using `IpcHandler`; see GEMINI.md for additional context

## 2. Build, Lint, Test
- No build step or automated lint/test suite is defined
- Prerequisites: `quickshell` (Qt6), `hyprland`, `qt6-qtwayland`, `qt6-quickcontrols2`, `qt6-svg`
- Run a module:
  ```bash
  quickshell -c <module>   # or: qs -c <module>
  ```
- IPC triggers:
  ```bash
  quickshell ipc -c <module> call <module> toggle
  quickshell ipc -c <module> call <module> open
  quickshell ipc -c <module> call <module> close
  ```
- Sandbox a single file:
  ```bash
  quickshell -p path/to/TestComponent.qml &
  ```
- Live debug log:
  ```bash
  quickshell -c <module> > debug.log 2>&1 &
  cat /run/user/1000/quickshell/by-id/$(ls -t /run/user/1000/quickshell/by-id | head -n 1)/log.qslog
  ```

## 3. Imports and Pragmas
- Pragmas come before all imports:
  ```qml
  //@ pragma UseQApplication
  //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
  //@ pragma IconTheme "Suru++"
  //@ pragma Env QS_ICON_THEME=Suru++
  ```
- Import order with a blank line between each group:
  1. Qt: `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `QtQuick.Shapes`, `QtQuick.Effects`
  2. Quickshell: `Quickshell`, `Quickshell.Io`, `Quickshell.Wayland`, `Quickshell.Hyprland`,
     `Quickshell.Services.SystemTray`, `Quickshell.Services.Pipewire`,
     `Quickshell.Services.Notifications`, `Quickshell.Bluetooth`
  3. Local relative imports (e.g., `import "./common"`)

## 4. Naming
- QML files: PascalCase; module entrypoint always `shell.qml`
- Root `id` in reusable components: `root`; in `ShellRoot` items: `shellRoot`
- All other IDs: camelCase, descriptive (never `item1`, `rect`, `container`)
- Properties, functions, and signals: camelCase
- IPC `target` strings: all-lowercase module name (e.g., `"notifications"`, `"overview"`)
- Use `required` properties in delegates for `modelData` and `index`

## 5. Formatting and Structure
- Indent: 4 spaces, never tabs
- Property order inside an element:
  1. `id`
  2. property declarations (`property type name: value`)
  3. signal handlers (`onSignal: ...`)
  4. core properties (`width`, `height`, `color`, `visible`, etc.)
  5. `anchors {}` block and Layout bindings
  6. child elements
  7. `states` / `transitions`
- Use hex colors or `Qt.rgba()`; never CSS `rgba(...)` strings
- Inline Nerd Font glyphs directly in `Text` elements; font: `"JetBrainsMono Nerd Font"`
- Keep inline JavaScript small; extract to named functions or `.js` files when logic grows

## 6. Types and Data
- Use strong property types: `bool`, `int`, `real`, `string`, `color`
- Use `property var` only for arrays or dynamic objects; prefer `property list<T>` for typed lists
- Use `required` in delegates to avoid undefined access
- Use QML 6 inline components for reusable sub-types within a file:
  ```qml
  component CommandProcess: Process { running: false }
  component NetworkDevice: QtObject { required property string name }
  ```
- Guard against empty/invalid external data before use

## 7. Singletons and Common Modules
- Shared appearance and config live in `common/` with a `qmldir` that registers them
- Declare singletons with both pragmas:
  ```qml
  pragma Singleton
  pragma ComponentBehavior: Bound
  import Quickshell
  Singleton { id: root }
  ```
  Register in `qmldir`: `singleton GlobalStates 1.0 GlobalStates.qml`
- Config-only singletons may use `QtObject` as the root type instead of `Singleton`
- Import via relative path: `import "./common"`
- `ColorUtils.qml` provides color helpers: `mix()`, `transparentize()`, `applyAlpha()`,
  `colorWithHueOf()`, `adaptToAccent()`

## 8. JavaScript Practices
- Use `const` / `let`, never `var`
- Strict equality: `===` / `!==`
- Optional chaining and nullish coalescing: `Hyprland.focusedMonitor?.name ?? ""`
- Array methods: `.filter()`, `.map()`, `.sort()`, `.find()`, `.reduce()`
- Template literals for composed commands or labels: `` `hyprctl dispatch workspace ${id}` ``
- `Qt.callLater(fn)` for deferred one-shot execution within the same event loop turn
- Prefer arrow functions for short inline callbacks

## 9. Error Handling and Safety
- Always check objects exist before calling methods
- Guard external command output before JSON parsing; check `.trim()` or wrap in `try/catch`
- Use `Connections { target: x }` with null-safe target; handle target being `undefined`
- Prefer signal-driven updates over one-off reads in `Component.onCompleted` for
  Hyprland and `DesktopEntries` data (race conditions are common at startup)
- Use `Quickshell.execDetached([...])` for fire-and-forget commands
- Use `StringUtils.shellSingleQuoteEscape()` for shell strings derived from user input

## 10. External Process Pattern
Run commands via `Process` + `StdioCollector`; trigger by setting `running = true`:
```qml
Process {
    id: myProc
    command: ["bash", "-c", "some-command --flag"]
    stdout: StdioCollector {
        onStreamFinished: {
            const lines = text.trim().split("\n");
            // update properties
        }
    }
}
```
For streaming line-by-line output use `SplitParser { onRead: data => { } }`.

## 11. IPC and Window Behavior
- Every module exposes `toggle`, `open`, `close` via `IpcHandler { target: "modulename" }`
- Known targets: `applauncher`, `audio`, `bluetooth`, `controlcenter`, `dashboard`,
  `network`, `notifications`, `overview`, `powermenu`, `search`, `wallpaper`, `waybar`
- Use `PanelWindow` for overlays; set `WlrLayershell.namespace`, `.layer: WlrLayer.Overlay`,
  and `.keyboardFocus: WlrKeyboardFocus.Exclusive`
- Target focused screen: iterate `Quickshell.screens.values`, match `screen.name` against
  `Hyprland.focusedMonitor?.name ?? ""`, fall back to index 0
- For all-screens display: `Variants { model: Quickshell.screens }` (used by overview)
- Always provide a background `MouseArea` (closes panel) and an inner `MouseArea` with
  `hoverEnabled: true; preventStealing: true` to consume clicks inside the panel
- Handle Escape via `Shortcut { sequence: "Escape" }` or `Keys.onEscapePressed`

## 12. Lists and Models
- Use `ListView` / `Repeater` with `required` delegate properties
- JS array models: `model: root.filteredItems`; for QML-tracked filtered lists use
  `ScriptModel { values: root.filteredItems }`
- Built-in providers: `DesktopEntries.applications.values`, `SystemTray.items`,
  `Bluetooth.devices.values`, `ToplevelManager.toplevels`, `Quickshell.screens`
- Debounce heavy computations triggered by user input:
  ```qml
  Timer { id: debounce; interval: 60; onTriggered: computeResults() }
  onQueryChanged: debounce.restart()
  ```
- `boundsBehavior: Flickable.StopAtBounds` for stable scrolling

## 13. Resources and Assets
- Icons: `Quickshell.iconPath(name, size)` with a fallback icon name
- Local assets and scripts: `Quickshell.shellPath("assets/file")` or `Quickshell.shellPath("scripts/run.sh")`
- Store module assets in `<module>/assets/`; avoid hardcoded absolute system paths

## 14. Animations
- Animate property changes with `Behavior`:
  ```qml
  Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
  Behavior on color   { ColorAnimation { duration: 200 } }
  ```
- In modules with an `Appearance` singleton use `Appearance.animation.*` for centralized config
- For `ListView` use `add`, `remove`, `displaced` transitions with `NumberAnimation`
- Poll system stats with a `Timer { repeat: true }` that starts/stops with panel visibility

## 15. Theming
- Theme: Catppuccin Mocha Dark; do not introduce arbitrary colors
- Full palette:
  - Base: `#1e1e2e` | Mantle: `#181825` | Crust: `#11111b`
  - Surface0: `#313244` | Surface1: `#45475a` | Surface2: `#585b70`
  - Text: `#cdd6f4` | Subtext1: `#bac2de` | Subtext0: `#a6adc8`
  - Blue: `#89b4fa` | Lavender: `#b4befe` | Mauve: `#cba6f7` | Pink: `#f5c2e7`
  - Red: `#f38ba8` | Peach: `#fab387` | Yellow: `#f9e2af`
  - Green: `#a6e3a1` | Teal: `#94e2d5` | Flamingo: `#f2cdcd` | Rosewater: `#f5e0dc`
  - Overlay/scrim: `#66000000`
- In modules with `Appearance.qml` use `Appearance.colors.*` and `Appearance.m3colors.*`
- Prefer border-radius 8 or 12; use consistent spacing for visual hierarchy

## 16. Repo Workflows
- Keep modules independent; do not merge unrelated tools into one module
- After changes, restart only the affected module to validate
- Expect async population of Hyprland data; use `Connections` and signals, not one-shot reads
- Avoid expensive work in property bindings that re-evaluate every frame

## 17. Cursor/Copilot Rules
- No Cursor rules found in `.cursor/rules/` or `.cursorrules`
- No Copilot rules found in `.github/copilot-instructions.md`

## 18. Quick References
- All entrypoints: `applauncher/shell.qml`, `audio/shell.qml`, `bluetooth/shell.qml`,
  `controlcenter/shell.qml`, `dashboard/shell.qml`, `network/shell.qml`,
  `notifications/shell.qml`, `overview/shell.qml`, `powermenu/shell.qml`,
  `search/shell.qml`, `wallpaper/shell.qml`, `waybar/shell.qml`
- Appearance/Config singletons: `<module>/common/Appearance.qml`, `<module>/common/Config.qml`
- Search providers: `search/services/{AppSearch,WebSearch,MathSearch,EmojiSearch,ClipboardSearch,ShellCommandSearch,ActionSearch}.qml`
- Network backend: `network/services/Nmcli.qml`, `network/services/SpeedTest.qml`
- Emoji data: `search/assets/emoji.txt`
- Additional docs: `GEMINI.md`, `overview/README.md`, `notifications/README.md`
