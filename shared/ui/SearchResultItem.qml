import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string title: ""
    property string subtitle: ""
    property bool selected: false
    property bool clickable: true
    property bool itemEnabled: true
    property int minHeight: 56
    property int horizontalPadding: 14
    property int verticalPadding: Tokens.space.s12
    property int itemRadius: Tokens.shape.medium
    property Component leading
    property Component trailing

    implicitHeight: Math.max(root.minHeight, contentLayout.implicitHeight + root.verticalPadding * 2)
    radius: root.itemRadius
    color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.12) : "transparent"
    border.width: selected ? Tokens.border.width.thin : 0
    border.color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.26) : "transparent"
    opacity: itemEnabled ? 1 : Tokens.opacities.disabled

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable && root.itemEnabled
        hoverEnabled: root.clickable && root.itemEnabled
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(root.selected ? Tokens.color.primary : Tokens.color.text.primary, mouseArea.pressed
            ? Tokens.stateLayer.pressed
            : mouseArea.containsMouse
                ? Tokens.stateLayer.hover
                : 0)
    }

    Rectangle {
        visible: root.selected
        width: 3
        radius: width / 2
        color: Tokens.color.primary
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: Tokens.space.s12
        anchors.bottomMargin: Tokens.space.s12
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        spacing: Tokens.space.s12

        Loader {
            active: root.leading !== undefined && root.leading !== null
            sourceComponent: root.leading
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Tokens.space.s2

            Text {
                text: root.title
                color: Tokens.color.text.primary
                font.family: Tokens.font.family.body
                font.pixelSize: Tokens.font.size.body
                font.weight: Tokens.font.weight.medium
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Tokens.color.text.secondary
                font.family: Tokens.font.family.caption
                font.pixelSize: Tokens.font.size.caption
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Loader {
            active: root.trailing !== undefined && root.trailing !== null
            sourceComponent: root.trailing
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
