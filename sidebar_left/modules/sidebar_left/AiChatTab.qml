import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Item {
    id: root

    function focusPrimaryInput() {
        composer.forceActiveFocus();
    }

    function submitMessage() {
        const cleaned = Utils.trim(composer.text);
        if (!cleaned.length || ChatService.busy) return;
        composer.clear();
        ChatService.sendUserMessage(cleaned);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Design.Tokens.space.s12

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            Text {
                Layout.fillWidth: true
                text: "Conversation"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.label
                font.weight: Design.Tokens.font.weight.semibold
            }

            DS.Button {
                text: "Clear chat"
                variant: "ghost"
                preferredHeight: 36
                disabled: ChatService.messages.length === 0
                onClicked: ChatService.clearMessages()
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            visible: ChatService.error.length > 0
            kind: "error"
            title: "Request failed"
            message: ChatService.error
        }

        DS.Surface {
            Layout.fillWidth: true
            Layout.fillHeight: true
            variant: "surfaceContainerLow"
            padding: Design.Tokens.space.s12
            clipContent: true

            ColumnLayout {
                anchors.fill: parent
                spacing: Design.Tokens.space.s8

                ListView {
                    id: messageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Design.Tokens.space.s8
                    model: ChatService.messages
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: ChatMessageDelegate {
                        width: messageList.width
                        message: modelData
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: ChatService.busy ? busyChip.implicitHeight : 0
                    visible: ChatService.busy

                    DS.Chip {
                        id: busyChip
                        anchors.left: parent.left
                        text: "Generating response..."
                        selected: true
                    }
                }
            }

            DS.FeedbackBlock {
                anchors.centerIn: parent
                width: Math.min(parent.width - Design.Tokens.space.s24, 320)
                visible: ChatService.messages.length === 0
                kind: "info"
                title: "No messages yet"
                message: "Pick a provider, write a prompt, and press Enter to send. Shift+Enter inserts a newline."
            }
        }

        DS.Surface {
            Layout.fillWidth: true
            variant: "surfaceContainerHigh"
            padding: Design.Tokens.space.s12

            RowLayout {
                anchors.fill: parent
                spacing: Design.Tokens.space.s8

                TextArea {
                    id: composer
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(58, Math.min(148, contentHeight + Design.Tokens.space.s16))
                    wrapMode: TextArea.Wrap
                    placeholderText: "Message the model..."
                    color: Design.Tokens.color.text.primary
                    selectedTextColor: Design.Tokens.color.text.inverse
                    selectionColor: Design.Tokens.color.primary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.body
                    leftPadding: Design.Tokens.space.s12
                    rightPadding: Design.Tokens.space.s12
                    topPadding: Design.Tokens.space.s8
                    bottomPadding: Design.Tokens.space.s8

                    background: Rectangle {
                        radius: Design.Tokens.shape.large
                        color: Design.Tokens.color.surface
                        border.width: Design.Tokens.border.width.thin
                        border.color: composer.activeFocus ? Design.Tokens.color.focusRing : Design.Tokens.color.outlineVariant
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (event.modifiers & Qt.ShiftModifier) {
                                return;
                            }
                            root.submitMessage();
                            event.accepted = true;
                        }
                    }
                }

                DS.Button {
                    Layout.alignment: Qt.AlignBottom
                    preferredHeight: 44
                    text: ChatService.busy ? "Busy" : "Send"
                    disabled: !Utils.trim(composer.text).length || ChatService.busy
                    onClicked: root.submitMessage()
                }
            }
        }
    }

    Connections {
        target: ChatService

        function onMessagesChanged() {
            Qt.callLater(messageList.positionViewAtEnd);
        }

        function onBusyChanged() {
            Qt.callLater(messageList.positionViewAtEnd);
        }
    }
}
