import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    property string kind: "info"
    property string title: ""
    property string message: ""

    readonly property color tone: {
        if (kind === "success") return Tokens.color.success;
        if (kind === "warning") return Tokens.color.warning;
        if (kind === "error") return Tokens.color.error;
        return Tokens.color.info;
    }
    readonly property color backgroundTone: {
        if (kind === "success") return Tokens.color.successContainer;
        if (kind === "warning") return Tokens.color.warningContainer;
        if (kind === "error") return Tokens.color.errorContainer;
        return Tokens.color.infoContainer;
    }

    radius: Tokens.shape.large
    color: backgroundTone
    border.width: Tokens.border.width.thin
    border.color: ThemePalette.withAlpha(tone, 0.30)

    implicitHeight: column.implicitHeight + Tokens.space.s16 * 2

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Tokens.space.s16
        spacing: Tokens.space.s4

        Text {
            visible: root.title !== ""
            text: root.title
            color: Tokens.color.text.primary
            font.family: Tokens.font.family.label
            font.pixelSize: Tokens.font.size.body
            font.weight: Tokens.font.weight.semibold
        }

        Text {
            visible: root.message !== ""
            text: root.message
            color: Tokens.color.text.secondary
            font.family: Tokens.font.family.body
            font.pixelSize: Tokens.font.size.label
            wrapMode: Text.Wrap
        }
    }
}
