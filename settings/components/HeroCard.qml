import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS

DS.Card {
    id: root

    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property color accentColor: Design.Tokens.color.primary
    default property alias contentData: contentColumn.data
    property alias actionData: actions.data

    Layout.fillWidth: true

    ColumnLayout {
        width: parent.width
        spacing: Design.Tokens.space.s16

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s16

            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: Design.Tokens.shape.full
                color: Design.ThemePalette.withAlpha(root.accentColor, Design.ThemeSettings.isDark ? 0.24 : 0.18)

                DS.LucideIcon {
                    anchors.centerIn: parent
                    visible: root.iconName !== ""
                    name: root.iconName
                    color: root.accentColor
                    iconSize: 24
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s4

                Text {
                    text: root.title
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.title
                    font.pixelSize: Design.Tokens.font.size.title
                    font.weight: Design.Tokens.font.weight.semibold
                }

                Text {
                    visible: root.subtitle !== ""
                    text: root.subtitle
                    color: Design.Tokens.color.text.secondary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.body
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                id: actions
                spacing: Design.Tokens.space.s8
            }
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12
        }
    }
}
