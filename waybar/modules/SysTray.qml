import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

import ".." as Root

Item {
    id: root

    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            MouseArea {
                required property SystemTrayItem modelData

                width: Root.Config.iconSize + 2
                height: Root.Config.iconSize + 2
                anchors.verticalCenter: parent.verticalCenter
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: (event) => {
                    if (event.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (event.button === Qt.RightButton) {
                        // Show the native platform context menu
                        // display() takes: parentWindow, relativeX, relativeY
                        if (modelData.hasMenu) {
                            var pos = mapToItem(null, 0, height);
                            modelData.display(QsWindow.window, pos.x, pos.y);
                        }
                    }
                }

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    sourceSize: Qt.size(Root.Config.iconSize, Root.Config.iconSize)
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
