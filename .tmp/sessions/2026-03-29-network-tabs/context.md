# Task Context: Network Module Transformation

Session ID: 2026-03-29-network-tabs
Created: 2026-03-29T14:00:00Z
Status: in_progress

## Current Request
Transform the existing network module into a 2-tab interface:
1. **Network Activity**: Live monitoring of inbound/outbound traffic, system info cards (IP, Gateway, DNS, MAC), and an "Active Connections" table.
2. **Speed Test**: A dedicated speed test view with a circular gauge, Ping/Jitter/Packet Loss cards, and a history table.

## Context Files (Standards to Follow)
- core/standards/code-quality.md
- AGENTS.md (Project Root)

## Reference Files (Source Material to Look At)
- network/shell.qml
- network/services/Nmcli.qml
- network/services/NetSpeed.qml
- network/services/SpeedTest.qml
- network/components/EthernetCard.qml

## External Docs Fetched
- None yet.

## Components
- `Sidebar.qml`: Navigation between tabs.
- `NetworkActivity.qml`: Tab 1 content.
- `SpeedTestView.qml`: Tab 2 content.
- `Connections.qml`: Service to fetch active connections.

## Constraints
- Use Catppuccin Mocha palette.
- Use JetBrainsMono Nerd Font.
- Modular and functional programming principles.
- No `nethogs` available; use `ss` for connections.

## Exit Criteria
- [ ] Sidebar navigation works.
- [ ] Network Activity tab shows correct system info and live chart.
- [ ] Active Connections table lists current connections with process info.
- [ ] Speed Test tab shows gauge and results.
- [ ] UI matches the provided images as closely as possible within Quickshell/QML.
