# Quickshell Notifications

A lightweight, standalone popup notifications + history panel module for Hyprland/Quickshell, themed with Catppuccin Mocha. Built to be clean and self-contained without relying on excessive external libraries.

## Features
- Real-time popups with actionable buttons and images.
- History panel overlay with clear-all functionality.
- Fully adapted to the Catppuccin Mocha aesthetic.
- Natively integrated with `Quickshell.Services.Notifications`.

## Run
```bash
quickshell -c notifications &
```

## IPC
Control the history panel using the built-in IPC handler:
```bash
qs ipc -c notifications call notifications toggle
qs ipc -c notifications call notifications open
qs ipc -c notifications call notifications close
qs ipc -c notifications call notifications clear
```

## Hyprland keybind example
```conf
bind = SUPER, N, exec, qs ipc -c notifications call notifications toggle
```
