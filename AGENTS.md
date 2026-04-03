# Repository Guidelines

## Project Structure & Module Organization
This repository is a modular Quickshell setup for Hyprland. Each feature lives in its own directory, such as `waybar/`, `overview/`, `notifications/`, `search/`, and `desktop_controlcenter/`, with a standalone `shell.qml` entrypoint. Most modules follow the same layout: `common/` for singletons and theme/config, `services/` for process and data logic, `modules/` or `components/` for UI, and `assets/` for static resources. Use `example/quickshell/` as reference material, not the primary implementation.

## Build, Test, and Development Commands
There is no formal build or automated test suite; validation is done by running modules directly.

- `qs -c waybar` or `quickshell -c notifications`: run a module locally.
- `quickshell -p path/to/Component.qml`: sandbox a single component.
- `qs ipc -c notifications call notifications toggle`: exercise IPC handlers.
- `tail -f /run/user/1000/quickshell/by-id/<latest>/log.qslog`: inspect live runtime logs.

Prefer testing the specific module you changed instead of restarting the entire shell.

## Coding Style & Naming Conventions
Use QML with 4-space indentation and no tabs. Keep pragmas at the top, then group imports as Qt, Quickshell, and local imports. Name files in `PascalCase.qml`; use `camelCase` for properties, functions, and most ids; reserve `root` for reusable component roots. Prefer typed properties like `bool`, `int`, and `property list<T>` over loose `var`, and use `required` in delegates. In embedded JavaScript, use `const`/`let`, `===`, optional chaining, and nullish coalescing.

Follow the shared theme conventions: use `Appearance.colors.*` or related singleton properties, keep colors in hex/`Qt.rgba()`, and use `"JetBrainsMono Nerd Font"` for text.

## Testing Guidelines
After changes, run the affected module, trigger relevant IPC methods, and watch logs for QML errors or failed processes. If the change affects overlays or monitor-aware UI, verify behavior on the focused monitor and confirm background click-to-close behavior still works.

## Commit & Pull Request Guidelines
Recent history follows conventional prefixes such as `feat`, `fix`, `style`, and `refactor(scope): summary`. Keep commit subjects short and scoped by module when useful, for example `fix(notifications): guard null image payload`. Pull requests should include a short summary, affected modules, manual verification steps, and screenshots or GIFs for visible UI changes. Call out IPC, config, or external command changes explicitly.
