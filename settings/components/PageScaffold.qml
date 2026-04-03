import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../shared/designsystem" as Design

Item {
    id: root

    property string title: ""
    property string description: ""
    property var context: null
    default property alias contentData: contentColumn.data
    readonly property int maxContentWidth: 980

    function focusEntry(entryId) {
        return;
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Item {
            width: Math.max(scrollView.availableWidth, 1)
            implicitHeight: pageColumn.implicitHeight

            ColumnLayout {
                id: pageColumn
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, root.maxContentWidth)
                spacing: Design.Tokens.space.s20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s4

                    Text {
                        text: root.title
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.headline
                        font.pixelSize: Design.Tokens.font.size.headline
                        font.weight: Design.Tokens.font.weight.semibold
                    }

                    Text {
                        visible: root.description !== ""
                        text: root.description
                        color: Design.Tokens.color.text.secondary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.body
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }

                ColumnLayout {
                    id: contentColumn
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s16
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Design.Tokens.space.s24
                }
            }
        }
    }
}
