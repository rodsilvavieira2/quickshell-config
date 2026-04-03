import QtQuick
import QtQuick.Controls
import "../designsystem"

ComboBox {
    id: root

    textRole: "label"
    valueRole: "value"
    implicitHeight: Tokens.component.input.height

    font.family: Tokens.font.family.body
    font.pixelSize: Tokens.font.size.body

    background: Rectangle {
        radius: Tokens.component.input.radius
        color: Tokens.color.surfaceContainerHighest
        border.width: Tokens.border.width.thin
        border.color: root.activeFocus ? Tokens.color.focusRing : Tokens.color.outlineVariant
    }

    contentItem: Item {
        anchors.fill: parent

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Tokens.component.input.paddingX
            anchors.rightMargin: Tokens.component.input.paddingX + 20
            anchors.verticalCenter: parent.verticalCenter
            text: root.displayText
            color: Tokens.color.text.primary
            font.family: root.font.family
            font.pixelSize: root.font.pixelSize
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    indicator: LucideIcon {
        x: root.width - width - Tokens.space.s16
        y: root.height / 2 - height / 2
        name: "chevron-down"
        color: Tokens.color.text.secondary
        iconSize: Tokens.font.size.label + 1
    }

    popup: Popup {
        y: root.height + Tokens.space.s4
        width: root.width
        padding: Tokens.space.s4
        background: Rectangle {
            radius: Tokens.shape.large
            color: Tokens.color.surfaceContainerHigh
            border.width: Tokens.border.width.thin
            border.color: Tokens.color.outlineVariant
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
        }
    }

    delegate: ItemDelegate {
        width: root.width - Tokens.space.s8
        height: Tokens.component.listItem.minHeight
        background: Rectangle {
            radius: Tokens.shape.medium
            color: highlighted ? ThemePalette.withAlpha(Tokens.color.primary, 0.16) : "transparent"
        }

        contentItem: Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Tokens.space.s12
            anchors.rightMargin: Tokens.space.s12
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.label ?? modelData
            color: highlighted ? Tokens.color.primary : Tokens.color.text.primary
            font.family: Tokens.font.family.body
            font.pixelSize: Tokens.font.size.body
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
