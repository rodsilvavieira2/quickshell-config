import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false

    implicitHeight: 86
    radius: Tokens.radius.xl
    color: checked
        ? ThemePalette.withAlpha(Tokens.color.accent.primary, ThemeSettings.isDark ? 0.18 : 0.16)
        : Tokens.color.bg.elevated
    border.width: Tokens.border.width.thin
    border.color: checked ? ThemePalette.withAlpha(Tokens.color.accent.primary, 0.34) : Tokens.color.border.subtle

    Behavior on color {
        ColorAnimation {
            duration: Tokens.motion.duration.fast
            easing.type: Tokens.motion.easing.standard
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(Tokens.color.text.primary, ThemeSettings.isDark ? 0.04 : 0.03)
        opacity: mouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.motion.duration.fast
                easing.type: Tokens.motion.easing.standard
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Tokens.space.s16
        spacing: Tokens.space.s12

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Tokens.radius.lg
            color: checked
                ? ThemePalette.withAlpha(Tokens.color.accent.primary, ThemeSettings.isDark ? 0.2 : 0.12)
                : Tokens.color.bg.interactive

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: checked ? Tokens.color.accent.primary : Tokens.color.icon.primary
                font.family: Tokens.font.family.icon
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.space.s4

            Text {
                text: root.title
                color: Tokens.color.text.primary
                font.family: Tokens.font.family.label
                font.pixelSize: Tokens.font.size.body
                font.weight: Tokens.font.weight.semibold
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Tokens.color.text.secondary
                font.family: Tokens.font.family.caption
                font.pixelSize: Tokens.font.size.caption
            }
        }
    }
}
