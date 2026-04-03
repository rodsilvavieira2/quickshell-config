import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    title: "Appearance"
    description: "Material 3 adapted foundations for your shell, with controlled sync into GTK where it is safe."

    Component.onCompleted: context?.themeAdapter?.resetDrafts()

    PageSection {
        title: "Shell theme"
        description: "Control the shared shell mode, accent seed, font family, and scale."

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12

            Repeater {
                model: [
                    { label: "Dark", value: "dark" },
                    { label: "Light", value: "light" }
                ]

                DS.SegmentedButton {
                    required property var modelData
                    Layout.fillWidth: true
                    text: modelData.label
                    selected: context?.themeAdapter?.draftMode === modelData.value
                    onClicked: context.themeAdapter.draftMode = modelData.value
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            Text {
                text: "Accent seed"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.label
                font.weight: Design.Tokens.font.weight.semibold
            }

            Flow {
                Layout.fillWidth: true
                width: parent.width
                spacing: Design.Tokens.space.s12

                Repeater {
                    model: context?.themeAdapter?.accentOptions ?? []

                    Rectangle {
                        required property var modelData

                        width: 76
                        height: 76
                        radius: Design.Tokens.shape.large
                        color: modelData.value
                        border.width: context?.themeAdapter?.draftAccentColor === modelData.value
                            ? Design.Tokens.border.width.strong
                            : Design.Tokens.border.width.thin
                        border.color: context?.themeAdapter?.draftAccentColor === modelData.value
                            ? Design.Tokens.color.text.primary
                            : Design.Tokens.color.outlineVariant

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
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: context.themeAdapter.draftAccentColor = parent.modelData.value
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            Text {
                text: "Shell font"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.label
                font.weight: Design.Tokens.font.weight.semibold
            }

            Repeater {
                model: Design.FontCatalog.entries

                DS.ListItem {
                    required property var modelData

                    Layout.fillWidth: true
                    title: modelData.label
                    subtitle: modelData.category
                    valueText: context?.themeAdapter?.draftFontFamily === modelData.family ? "Selected" : ""
                    selected: context?.themeAdapter?.draftFontFamily === modelData.family
                    onClicked: context.themeAdapter.draftFontFamily = modelData.family
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12

            Repeater {
                model: context?.themeAdapter?.scaleOptions ?? []

                DS.SegmentedButton {
                    required property var modelData
                    Layout.fillWidth: true
                    text: modelData.label
                    selected: Math.abs(context?.themeAdapter?.draftUiScale - modelData.value) < 0.001
                    onClicked: context.themeAdapter.draftUiScale = modelData.value
                }
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            kind: context?.themeAdapter?.hasPendingChanges ? "warning" : "info"
            title: context?.themeAdapter?.hasPendingChanges ? "Pending changes" : "Shell theme applied"
            message: context?.themeAdapter?.hasPendingChanges
                ? "Apply the staged shell changes to update the shared Quickshell modules."
                : "The shell is currently using the values shown above."
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12

            DS.Button {
                text: "Reset"
                variant: "secondary"
                onClicked: context.themeAdapter.resetDrafts()
            }

            DS.Button {
                text: "Apply"
                variant: "primary"
                disabled: !context?.themeAdapter?.hasPendingChanges
                onClicked: context.themeAdapter.applyDrafts()
            }
        }
    }

    PageSection {
        title: "GTK bridge"
        description: "Keep GTK readable and predictable without letting external themes drive the shell."

        DS.SwitchRow {
            Layout.fillWidth: true
            title: "Prefer dark GTK apps"
            subtitle: `GTK currently uses ${context?.gtkAdapter?.themeName ?? "Adwaita"} with ${context?.gtkAdapter?.iconThemeName ?? "the current icon theme"}.`
            checked: context?.gtkAdapter?.preferDark ?? true
            onToggled: checked => context.gtkAdapter.apply(checked, context.gtkAdapter.gtkFontName)
        }

        DS.NavigationRow {
            Layout.fillWidth: true
            title: "GTK font"
            subtitle: context?.gtkAdapter?.gtkFontName ?? ""
            valueText: "Sync to shell font"
            onClicked: context.gtkAdapter.syncFromTheme(context.themeAdapter.draftMode, context.themeAdapter.draftFontFamily)
        }
    }

    PageSection {
        title: "Preview"
        description: "The shared primitives below reflect the current token set."

        DS.Panel {
            Layout.fillWidth: true
            padding: Design.Tokens.space.s20

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.TopAppBar {
                    Layout.fillWidth: true
                    title: "Desktop settings preview"
                    subtitle: "Top app bar, tonal surfaces, and primary actions"

                    DS.Button {
                        text: "Primary"
                        variant: "primary"
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
                    }
                }

                DS.ListItem {
                    Layout.fillWidth: true
                    icon: "󰍹"
                    title: "Display scale"
                    subtitle: "Lists and rows stay neutral until selected."
                    valueText: "100%"
                    selected: true
                }

                DS.FeedbackBlock {
                    Layout.fillWidth: true
                    kind: "info"
                    title: "M3 adapted"
                    message: "The shell uses Material 3 structure and roles while keeping the desktop’s darker, quieter look."
                }
            }
        }
    }
}
