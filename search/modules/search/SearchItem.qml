import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/widgets"
import "../../services"
import "../../shared/designsystem" as Design

Rectangle {
    id: root

    required property var entry
    required property bool active
    required property int itemIndex

    implicitHeight: 56
    radius: 16
    color: root.active
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, Design.ThemeSettings.isDark ? 0.14 : 0.10)
        : hoverArea.containsMouse
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, Design.ThemeSettings.isDark ? 0.05 : 0.035)
            : "transparent"
    border.width: root.active ? 1 : 0
    border.color: root.active
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.22)
        : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 16
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        spacing: 13

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 34
            height: 34
            radius: 11
            color: root.active
                ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, Design.ThemeSettings.isDark ? 0.20 : 0.14)
                : Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHighest, Design.ThemeSettings.isDark ? 0.88 : 0.94)
            border.width: 1
            border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.55)

            StyledText {
                anchors.centerIn: parent
                text: root.entry.iconType === "text" ? (root.entry.iconName ?? "") : ""
                font.pixelSize: 16
                color: Appearance.colors.colOnLayer0
                visible: root.entry.iconType === "text"
            }

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                visible: root.entry.iconType === "system" || root.entry.iconType === "material"
                source: visible ? Quickshell.iconPath(root.entry.iconName ?? "", "application-x-executable") : ""
                sourceSize: Qt.size(20, 20)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.entry.name ?? ""
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.body
                font.pixelSize: Design.Tokens.font.size.body
                font.weight: Design.Tokens.font.weight.medium
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.entry.comment ?? ""
                visible: text.length > 0
                color: Design.ThemePalette.withAlpha(Design.Tokens.color.text.secondary, 0.92)
                font.family: Design.Tokens.font.family.caption
                font.pixelSize: Design.Tokens.font.size.caption
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.ListView.view.currentIndex = root.itemIndex
        onClicked: {
            if (root.entry && root.entry.execute) {
                root.entry.execute()
                GlobalStates.searchOpen = false
            }
        }
    }
}
