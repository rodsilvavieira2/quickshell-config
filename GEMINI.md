# Quickshell Desktop Configuration

A modular, high-performance desktop shell for Wayland, optimized for the Hyprland compositor. Built using the Quickshell framework with QtQuick/QML (Qt6).

## Project Overview

This repository contains independent Quickshell modules that collectively form a complete desktop environment. Each module is designed as a standalone daemon that communicates via IPC.

### Core Technologies
- **Framework:** [Quickshell](https://quickshell.org/) (Qt6/QML)
- **Compositor:** [Hyprland](https://hyprland.org/)
- **Language:** QML 2.15+ with embedded JavaScript
- **Theme:** Catppuccin Mocha Dark
- **IPC:** Quickshell `IpcHandler`

### Module Architecture
Each top-level directory (e.g., `notifications/`, `overview/`) follows a standard structure:
- `shell.qml`: The entry point for the module.
- `common/`: Contains singletons for `Appearance.qml` (theming) and `Config.qml` (behavior).
- `services/`: Backend logic, data providers (e.g., `HyprlandData.qml`), and global state management.
- `modules/`: UI components and widgets specific to the module.
- `assets/`: Icons, images, and static data.

## Key Modules

| Module | Purpose | Entry Point |
| :--- | :--- | :--- |
| `applauncher` | Application menu and search. | `applauncher/shell.qml` |
| `controlcenter` | System settings, toggles, and status. | `controlcenter/shell.qml` |
| `notifications` | Notification popups and history panel. | `notifications/shell.qml` |
| `overview` | Workspace grid and window preview. | `overview/shell.qml` |
| `search` | Global search (Apps, Emojis, Web, Math). | `search/shell.qml` |
| `waybar` | Desktop status bar with workspaces and tray. | `waybar/shell.qml` |
| `powermenu` | Logout, reboot, and shutdown options. | `powermenu/shell.qml` |

## Building and Running

### Prerequisites
- `quickshell` (Qt6 version)
- `hyprland`
- `qt6-qtwayland`, `qt6-quickcontrols2`, `qt6-svg`

### Commands
- **Run a module:**
  ```bash
  quickshell -c <module_name>
  # Example: quickshell -c notifications
  ```
- **IPC Interaction:**
  ```bash
  quickshell ipc -c <module_name> call <target> <method> [args...]
  # Example: quickshell ipc -c overview call overview toggle
  ```
- **Debug Logs:**
  ```bash
  quickshell -c <module_name> > debug.log 2>&1
  ```

## Development Conventions

### QML Standards
- **Indentation:** 4 spaces (no tabs).
- **Naming:** PascalCase for files, camelCase for `id`, properties, and functions.
- **Entry Points:** Always named `shell.qml`.
- **Imports:**
  1. Qt imports (Quick, Layouts, Controls)
  2. Quickshell imports
  3. Local relative imports
- **Pragmas:** Place at the very top of the file (e.g., `//@ pragma UseQApplication`).

### Architectural Patterns
- **Singletons:** Use `pragma Singleton` for `Appearance` and `Config` in `common/`.
- **Property Order:**
  1. `id`
  2. Property declarations (`property type name`)
  3. Signal handlers (`onClicked`, etc.)
  4. Core properties (`width`, `height`, `color`)
  5. Anchors and Layout bindings (keep `anchors {}` grouped)
  6. Child elements
- **IPC:** Use `IpcHandler` for all cross-process or script-based triggers.
- **Safety:** Always guard against `undefined` or null targets in `Connections` and external command outputs.

### Theming (Catppuccin Mocha)
- Background: `#1e1e2e`
- Primary Text: `#cdd6f4`
- Secondary Text: `#a6adc8`
- Accent (Blue): `#89b4fa`
- Surface: `#313244`

## Important Files
- `AGENTS.md`: Detailed coding standards and agent-specific instructions.
- `notifications/README.md`: Specific documentation for the notification system.
- `overview/README.md`: Setup and configuration for the workspace overview.
