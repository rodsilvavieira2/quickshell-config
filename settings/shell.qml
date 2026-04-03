//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./shared/designsystem" as Design
import "./shared/ui" as DS

ShellRoot {
    id: shellRoot

    property bool panelOpen: false
    property string draftMode: Design.ThemeSettings.mode
    property string draftAccentColor: Design.ThemeSettings.accentColor
    property string draftFontFamily: Design.ThemeSettings.fontFamily
    property real draftUiScale: Design.ThemeSettings.uiScale
    readonly property bool hasPendingChanges:
        draftMode !== Design.ThemeSettings.mode
        || draftAccentColor !== Design.ThemeSettings.accentColor
        || draftFontFamily !== Design.ThemeSettings.fontFamily
        || Math.abs(draftUiScale - Design.ThemeSettings.uiScale) > 0.001

    readonly property var accentOptions: [
        { name: "Blue", value: "#4f8cff" },
        { name: "Cyan", value: "#22c3ee" },
        { name: "Emerald", value: "#2fbf71" },
        { name: "Amber", value: "#f5a524" },
        { name: "Rose", value: "#f25f7a" },
        { name: "Violet", value: "#8b5cf6" }
    ]

    readonly property var scaleOptions: [
        { label: "90%", value: 0.9 },
        { label: "100%", value: 1.0 },
        { label: "110%", value: 1.1 }
    ]

    function resetDrafts() {
        draftMode = Design.ThemeSettings.mode;
        draftAccentColor = Design.ThemeSettings.accentColor;
        draftFontFamily = Design.ThemeSettings.fontFamily;
        draftUiScale = Design.ThemeSettings.uiScale;
    }

    function applyDrafts() {
        Design.ThemeSettings.apply(draftMode, draftAccentColor, draftFontFamily, draftUiScale);
        resetDrafts();
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            resetDrafts();
        }
    }

    IpcHandler {
        target: "settings"

        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }

        function open() {
            shellRoot.panelOpen = true;
        }

        function close() {
            shellRoot.panelOpen = false;
        }
    }

    PanelWindow {
        id: window

        property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                const currentScreen = Quickshell.screens.values[i];
                if (currentScreen.name === focusedScreenName) {
                    return currentScreen;
                }
            }

            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }

        visible: shellRoot.panelOpen || panelContent.opacity > 0
        color: "transparent"

        WlrLayershell.namespace: "quickshell:settings"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shellRoot.panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        DS.OverlayScrim {
            anchors.fill: parent
            opacity: panelContent.opacity

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.fast
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: shellRoot.panelOpen
            onClicked: shellRoot.panelOpen = false
        }

        Item {
            id: panelContent
            anchors.centerIn: parent
            width: Math.min((window.screen?.width ?? 1280) * 0.82, 980)
            height: Math.min((window.screen?.height ?? 900) * 0.86, 860)
            opacity: shellRoot.panelOpen ? 1 : 0
            scale: shellRoot.panelOpen ? 1 : 0.98

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.normal
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.normal
                    easing.type: Design.Tokens.motion.easing.decelerate
                }
            }

            FocusScope {
                anchors.fill: parent
                focus: shellRoot.panelOpen

                Keys.onEscapePressed: event => {
                    shellRoot.panelOpen = false;
                    event.accepted = true;
                }

                DS.Panel {
                    id: panel
                    anchors.fill: parent
                    backgroundColor: Design.Tokens.color.bg.surface
                    borderColor: Design.Tokens.color.border.strong

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Design.Tokens.space.s20

                        DS.HeaderBlock {
                            Layout.fillWidth: true
                            title: "Desktop UI"
                            subtitle: "Global design system settings for your Quickshell modules"

                            DS.Button {
                                text: "Apply"
                                variant: "primary"
                                preferredHeight: 36
                                disabled: !shellRoot.hasPendingChanges
                                onClicked: shellRoot.applyDrafts()
                            }

                            DS.IconButton {
                                icon: "󰅖"
                                preferredHeight: 36
                                onClicked: shellRoot.panelOpen = false
                            }
                        }

                        Flickable {
                            id: flickable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            contentHeight: contentColumn.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true

                            ColumnLayout {
                                id: contentColumn
                                width: flickable.width
                                spacing: Design.Tokens.space.s20

                                DS.Card {
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: Design.Tokens.space.s16

                                        DS.HeaderBlock {
                                            Layout.fillWidth: true
                                            title: "Appearance"
                                            subtitle: "Choose the global mode and accent without recoloring the whole interface"
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Design.Tokens.space.s12

                                            DS.Button {
                                                Layout.fillWidth: true
                                                text: "Dark"
                                                variant: shellRoot.draftMode === "dark" ? "primary" : "secondary"
                                                onClicked: shellRoot.draftMode = "dark"
                                            }

                                            DS.Button {
                                                Layout.fillWidth: true
                                                text: "Light"
                                                variant: shellRoot.draftMode === "light" ? "primary" : "secondary"
                                                onClicked: shellRoot.draftMode = "light"
                                            }
                                        }

                                        Flow {
                                            Layout.fillWidth: true
                                            width: parent.width
                                            spacing: Design.Tokens.space.s12

                                            Repeater {
                                                model: shellRoot.accentOptions

                                                Rectangle {
                                                    required property var modelData

                                                    width: 68
                                                    height: 68
                                                    radius: Design.Tokens.radius.lg
                                                    color: modelData.value
                                                    border.width: shellRoot.draftAccentColor === modelData.value
                                                        ? Design.Tokens.border.width.strong
                                                        : Design.Tokens.border.width.thin
                                                    border.color: shellRoot.draftAccentColor === modelData.value
                                                        ? Design.Tokens.color.text.primary
                                                        : Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.15)

                                                    Text {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        anchors.bottom: parent.bottom
                                                        anchors.bottomMargin: Design.Tokens.space.s8
                                                        text: modelData.name
                                                        color: "#ffffff"
                                                        font.family: Design.Tokens.font.family.label
                                                        font.pixelSize: Design.Tokens.font.size.caption
                                                        font.weight: Design.Tokens.font.weight.semibold
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: shellRoot.draftAccentColor = parent.modelData.value
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                DS.Card {
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: Design.Tokens.space.s16

                                        DS.HeaderBlock {
                                            Layout.fillWidth: true
                                            title: "Typography"
                                            subtitle: "Text fonts are configurable; icon glyphs stay fixed for reliability"
                                        }

                                        Repeater {
                                            model: Design.FontCatalog.entries

                                            DS.ListItem {
                                                required property var modelData

                                                Layout.fillWidth: true
                                                title: modelData.label
                                                subtitle: modelData.category
                                                valueText: shellRoot.draftFontFamily === modelData.family ? "Selected" : ""
                                                selected: shellRoot.draftFontFamily === modelData.family
                                                onClicked: shellRoot.draftFontFamily = modelData.family
                                            }
                                        }

                                        DS.HeaderBlock {
                                            Layout.fillWidth: true
                                            title: "Scale"
                                            subtitle: "Small controlled size steps for text and control heights"
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Design.Tokens.space.s12

                                            Repeater {
                                                model: shellRoot.scaleOptions

                                                DS.Button {
                                                    required property var modelData

                                                    Layout.fillWidth: true
                                                    text: modelData.label
                                                    variant: Math.abs(shellRoot.draftUiScale - modelData.value) < 0.001 ? "primary" : "secondary"
                                                    onClicked: shellRoot.draftUiScale = modelData.value
                                                }
                                            }
                                        }

                                        DS.FeedbackBlock {
                                            Layout.fillWidth: true
                                            kind: shellRoot.hasPendingChanges ? "warning" : "info"
                                            title: shellRoot.hasPendingChanges ? "Pending changes" : "Applied style"
                                            message: shellRoot.hasPendingChanges
                                                ? "Your changes are staged. Click Apply to propagate them to running modules."
                                                : "This panel is showing the currently applied theme values."
                                        }
                                    }
                                }

                                DS.Card {
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: Design.Tokens.space.s16

                                        DS.HeaderBlock {
                                            Layout.fillWidth: true
                                            title: "Preview"
                                            subtitle: "Shared components update live from the active token set"
                                        }

                                        DS.Panel {
                                            Layout.fillWidth: true
                                            padding: Design.Tokens.space.s20

                                            ColumnLayout {
                                                width: parent.width
                                                spacing: Design.Tokens.space.s16

                                                DS.HeaderBlock {
                                                    Layout.fillWidth: true
                                                    title: "Now Playing"
                                                    subtitle: "Panel / Header / Action anatomy"

                                                    DS.Button {
                                                        text: "Open"
                                                        variant: "ghost"
                                                        preferredHeight: 34
                                                    }
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: Design.Tokens.space.s12

                                                    DS.ToggleTile {
                                                        Layout.fillWidth: true
                                                        icon: "󰖩"
                                                        title: "Wi-Fi"
                                                        subtitle: "Connected"
                                                        checked: true
                                                    }

                                                    DS.ToggleTile {
                                                        Layout.fillWidth: true
                                                        icon: "󰂯"
                                                        title: "Bluetooth"
                                                        subtitle: "Idle"
                                                        checked: false
                                                    }
                                                }

                                                DS.Card {
                                                    Layout.fillWidth: true

                                                    ColumnLayout {
                                                        width: parent.width
                                                        spacing: Design.Tokens.space.s12

                                                        Text {
                                                            text: "Output volume"
                                                            color: Design.Tokens.color.text.primary
                                                            font.family: Design.Tokens.font.family.title
                                                            font.pixelSize: Design.Tokens.font.size.body
                                                            font.weight: Design.Tokens.font.weight.semibold
                                                        }

                                                        DS.Slider {
                                                            Layout.fillWidth: true
                                                            value: 0.62
                                                        }

                                                        RowLayout {
                                                            Layout.fillWidth: true
                                                            spacing: Design.Tokens.space.s12

                                                            DS.Button {
                                                                text: "Primary"
                                                                variant: "primary"
                                                            }

                                                            DS.Button {
                                                                text: "Secondary"
                                                                variant: "secondary"
                                                            }

                                                            DS.Button {
                                                                text: "Ghost"
                                                                variant: "ghost"
                                                            }
                                                        }
                                                    }
                                                }

                                                DS.FeedbackBlock {
                                                    Layout.fillWidth: true
                                                    kind: "info"
                                                    title: "Feedback surface"
                                                    message: "Accent color is reserved for focus, selection and key actions."
                                                }

                                                DS.ListItem {
                                                    Layout.fillWidth: true
                                                    title: "Notification item"
                                                    subtitle: "Item / list / metadata alignment"
                                                    valueText: "2m ago"
                                                    selected: true
                                                }

                                                DS.ListItem {
                                                    Layout.fillWidth: true
                                                    title: "Calendar event"
                                                    subtitle: "Preview of secondary text, spacing and hover"
                                                    valueText: "14:30"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
