import QtQuick
import QtQuick.Layouts
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Item {
    id: root

    required property var message

    readonly property bool fromUser: message.role === "user"

    width: ListView.view ? ListView.view.width : 360
    implicitHeight: bubble.implicitHeight + Design.Tokens.space.s8

    DS.Surface {
        id: bubble

        width: root.width * 0.84
        anchors.right: root.fromUser ? parent.right : undefined
        anchors.left: root.fromUser ? undefined : parent.left
        variant: root.fromUser ? "surfaceContainerHighest" : "surfaceContainerLow"
        padding: Design.Tokens.space.s12
        backgroundColor: root.fromUser
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.14)
            : Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerLow, 0.92)
        borderColor: root.fromUser
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.30)
            : Design.Tokens.color.outlineVariant

        ColumnLayout {
            anchors.fill: parent
            spacing: Design.Tokens.space.s8

            Text {
                text: root.fromUser ? "You" : "Assistant"
                color: root.fromUser ? Design.Tokens.color.primary : Design.Tokens.color.text.secondary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.caption
                font.weight: Design.Tokens.font.weight.semibold
            }

            Text {
                Layout.fillWidth: true
                text: root.message.content
                textFormat: root.fromUser ? Text.PlainText : Text.MarkdownText
                wrapMode: Text.Wrap
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.body
                font.pixelSize: Design.Tokens.font.size.body
                lineHeight: 1.18
                onLinkActivated: link => Qt.openUrlExternally(link)
            }
        }
    }
}
