import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/widgets"
import "../../services"
import "."

Scope {
    id: historyScope

    PanelWindow {
        id: root
        property var focusedScreenName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i]
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null
        }

        visible: GlobalStates.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:notificationsHistory"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.panelOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => {
                GlobalStates.panelOpen = false
                event.accepted = true
            }
        }

        Rectangle {
            id: panel
            width: Config ? Config.options.panel.width : 380
            height: parent.height
            anchors.right: parent.right
            color: Appearance.colors.colBackground
            radius: 12
            border.color: Appearance.colors.colBorder
            border.width: 1
            anchors.margins: 12

            opacity: GlobalStates.panelOpen ? 1 : 0
            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                StyledText {
                    text: "Notifications"
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer0
                }

                Rectangle {
                    height: 1
                    Layout.fillWidth: true
                    color: Appearance.colors.colBorder
                }

                NotificationList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
