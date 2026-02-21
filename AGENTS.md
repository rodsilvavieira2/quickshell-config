# Quickshell Agent Guidelines

Welcome, Agent! This file outlines the conventions, architecture, and commands required to operate within this Quickshell codebase. Your goal is to adhere strictly to these guidelines when analyzing, modifying, or extending configurations.

## 1. Project Context & Architecture

- **Framework:** Quickshell (A Qt/QML based shell for Wayland compositors, specifically optimized for Hyprland).
- **Environment:** QtQuick, Wayland, Hyprland, IPC.
- **Language:** QML and embedded JavaScript (ES6+ features supported depending on Qt6 version).
- **Structure:** The codebase is divided into independent Quickshell configurations, each residing in its own subdirectory (e.g., `overview/`, `applauncher/`). 
  - Each configuration must have a root `shell.qml` file.
  - Configurations operate as separate daemon processes and communicate via IPC.

## 2. Build & Test Commands

Since this is a set of QML shell scripts rather than a compiled binary application, there is no traditional "build" step. 

### Starting a Configuration
To run or test a specific configuration module (e.g., `applauncher`):
```bash
quickshell -c applauncher &
# Alternatively, if 'qs' is aliased to 'quickshell':
qs -c applauncher &
```

### IPC Commands (Toggling and Controlling)
Quickshell modules often run in the background and expose actions via IPC using `IpcHandler`.
```bash
# Toggle the app launcher
quickshell ipc -c applauncher call applauncher toggle

# Open or close explicitly
quickshell ipc -c applauncher call applauncher open
quickshell ipc -c applauncher call applauncher close
```

### Running a "Single Test" (Sandboxing)
To test a single isolated QML file outside of the main configuration tree:
```bash
# Pass the explicit path using -p
quickshell -p path/to/TestComponent.qml &
```

### Logging and Debugging
Quickshell logs internally to `XDG_RUNTIME_DIR`. However, for immediate debugging during development, you can stream the standard output/error directly to a log file to trace QML errors:
```bash
quickshell -c applauncher > debug.log 2>&1 &
tail -f debug.log
```
Or view the most recent persistent logs:
```bash
cat /run/user/1000/quickshell/by-id/$(ls -t /run/user/1000/quickshell/by-id | head -n 1)/log.qslog
```

## 3. Code Style Guidelines

### File and Component Naming
- **QML Files:** Must be PascalCase (e.g., `OverviewWindow.qml`, `AppIcon.qml`), except for the main entry point which must be `shell.qml`.
- **IDs:** Must be camelCase and descriptive (e.g., `shellRoot`, `appList`, `searchInput`). Avoid generic IDs like `item1` or `rect`.
- **Properties & Functions:** Must use camelCase (e.g., `launcherOpen`, `filterApps()`).

### Imports
- Group imports logically.
- Core Qt imports first (`import QtQuick`, `import QtQuick.Controls`, `import QtQuick.Layouts`).
- Quickshell imports second (`import Quickshell`, `import Quickshell.Wayland`, etc.).
- Local directory/module imports last (`import "../../common"`).
- Always include necessary pragmas at the top of the file, such as:
  ```qml
  //@ pragma UseQApplication
  //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
  ```

### QML Formatting and Structure
- Structure QML properties in the following order inside an element:
  1. `id` (Always the first property).
  2. Custom `property` declarations.
  3. Signal handlers (`onClicked`, `onTextChanged`).
  4. Core properties (width, height, color).
  5. Anchors and Layout bindings (`anchors.fill: parent`, `Layout.fillWidth: true`).
  6. Child elements.
  7. States and Transitions.
- Use 4 spaces for indentation. Never use tabs.
- Use `Qt.rgba()` or standard hex codes (`#RRGGBB` or `#AARRGGBB`) for colors. QML does not support CSS-style `rgba(r, g, b, a)` strings.

### JavaScript inside QML
- Keep inline JS minimal. For complex logic, extract it into a JavaScript function declared at the top of the component or in a separate `.js` file if it becomes too large.
- Use `let` and `const` instead of `var` wherever possible. (Note: standard QML property declarations still require `property var` for dynamic arrays/objects, which is fine).
- Use strict equality (`===` and `!==`).
- Use modern ES6 features (Arrow functions, Template literals) safely within the Qt JS engine limits.

### Typing
- Define strong types for properties when known (e.g., `property bool launcherOpen`, `property int currentIndex`).
- Fall back to `property var` only for complex arrays or JSON objects.

### Error Handling & Safety
- **Optional Chaining:** Use optional chaining (`?.`) and nullish coalescing (`??`) extensively when accessing deeply nested properties, especially from external data sources like `DesktopEntries` or `Hyprland`.
  ```qml
  property string focusedMonitorName: Hyprland.focusedMonitor?.name ?? ""
  ```
- **Null Checks:** Always verify that an object or property exists before invoking methods on it.
  ```javascript
  if (app && app.execute) {
      app.execute();
  }
  ```
- **Connections & Signals:** When using `Connections`, target the specific QML object correctly. Be mindful of undefined targets on initialization. When listening to model changes (like `DesktopEntries.applications`), ensure you hook into appropriate signals like `onValuesChanged` and handle cases where values might briefly be empty/undefined.
- **Resource Lookups:** When looking up icons or resources, prefer robust fallback chains using provided tools (e.g., `Quickshell.iconPath("system-search-symbolic", "search")`). Avoid hardcoding absolute system paths.

## 4. Workflows and Best Practices

- **Modularity:** Keep configurations modular. Do not merge completely separate tools (e.g., a launcher and an overview widget) into the same Quickshell configuration namespace unless they strictly depend on each other. Isolate them in separate subdirectories.
- **Verification:** Before assuming a fix works, always restart the quickshell configuration and check the logs. Syntax errors or unresolved imports will immediately cause the configuration to fail on load.
- **Asynchronicity:** Be aware that Hyprland workspaces, clients, and system DesktopEntries are dynamically populated. Do not assume index `0` exists at startup. Listen to the appropriate signals instead of executing one-off queries in `Component.onCompleted`.

## 5. Theming & Visual Design

- **App Theme:** The current visual theme for the application is based on **Catppuccin Mocha Dark**.
- **Color Palette:** Stick strictly to these core colors when building or modifying QML components:
  - **Background (Base):** `#1e1e2e` (Used for main window and container backgrounds)
  - **Borders & Selected Items (Surface1/2):** `#313244` (Used for outlines, separators, and hover/selected states)
  - **Primary Text (Text):** `#cdd6f4` (Used for main titles and active input text)
  - **Secondary/Placeholder Text (Subtext0):** `#a6adc8` (Used for descriptions, generic names, and placeholder text)
  - **Overlays/Shadows:** `#66000000` (Used for semi-transparent backdrops/dimming effects behind floating windows)
- **Styling Directives:** Do not introduce arbitrary colors outside of this palette. Maintain a minimalist design approach, leveraging spacing, border-radius (e.g., `radius: 8` or `12`), and padding for layout hierarchy instead of excess elements.
