# Quickshell Notifications

Popup notifications + a history panel for Hyprland/Quickshell.

## Run
```bash
qs -c notifications &
```

## IPC
```bash
qs ipc -c notifications call notifications toggle
qs ipc -c notifications call notifications open
qs ipc -c notifications call notifications close
qs ipc -c notifications call notifications clear
qs ipc -c notifications call notifications silent
qs ipc -c notifications call notifications unsilent
```

## Hyprland keybind example
```conf
bind = SUPER, N, exec, qs ipc -c notifications call notifications toggle
```

## Notes
- Popups appear top-right on the focused monitor.
- History panel is a right-side overlay.
- Notifications persist to `~/.cache/notifications/notifications.json`.
