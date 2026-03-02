//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications

import "./components"

ShellRoot {
    id: shellRoot

    property bool historyOpen: false

    property list<var> allNotifications: []
    property list<var> popups: []
    property var popupTimers: ({})

    function clearAllNotifications() {
        notifServer.trackedNotifications.values.forEach(n => n.dismiss());
        shellRoot.allNotifications = [];
        shellRoot.popups = [];

        for (let id in shellRoot.popupTimers) {
            shellRoot.popupTimers[id].destroy();
        }
        shellRoot.popupTimers = {};
    }

    IpcHandler {
        target: "notifications"
        function toggle() { shellRoot.historyOpen = !shellRoot.historyOpen; }
        function open()   { shellRoot.historyOpen = true; }
        function close()  { shellRoot.historyOpen = false; }
        function clear()  { shellRoot.clearAllNotifications(); }
    }

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (notification) => {
            notification.tracked = true;
            let n = {
                id: notification.id,
                appIcon: notification.appIcon || "",
                appName: notification.appName || "Notification",
                summary: notification.summary || "",
                body: notification.body || "",
                image: notification.image || "",
                urgency: notification.urgency.toString() || "normal",
                actions: notification.actions || [],
                time: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat),
                source: notification
            };

            let currentAll = shellRoot.allNotifications;
            currentAll.unshift(n);
            shellRoot.allNotifications = currentAll;

            if (!shellRoot.historyOpen) {
                let currentPopups = shellRoot.popups;
                currentPopups.unshift(n);
                shellRoot.popups = currentPopups;

                let timeout = notification.expireTimeout > 0 ? notification.expireTimeout : 5000;
                let t = Qt.createQmlObject(
                    'import QtQuick; Timer { interval: ' + timeout + '; running: true; onTriggered: shellRoot.removePopup(' + n.id + ') }',
                    shellRoot
                );
                shellRoot.popupTimers[n.id] = t;
            }
        }
    }

    function removePopup(id) {
        shellRoot.popups = shellRoot.popups.filter(n => n.id !== id);
        if (shellRoot.popupTimers[id]) {
            shellRoot.popupTimers[id].destroy();
            delete shellRoot.popupTimers[id];
        }
    }

    function removeNotification(id) {
        removePopup(id);
        shellRoot.allNotifications = shellRoot.allNotifications.filter(n => n.id !== id);
        let n = notifServer.trackedNotifications.values.find(x => x.id === id);
        if (n) n.dismiss();
    }

    function invokeAction(notifId, actionId) {
        let n = notifServer.trackedNotifications.values.find(x => x.id === notifId);
        if (n) {
            let act = n.actions.find(a => a.identifier === actionId);
            if (act) act.invoke();
        }
        removeNotification(notifId);
    }

    // ── Popup toasts ────────────────────────────────────────────────────────────
    PanelWindow {
        id: popupWindow

        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName)
                    return Quickshell.screens.values[i];
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }

        visible: shellRoot.popups.length > 0 && !shellRoot.historyOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:notifications:popups"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Only anchor to the corner where notifications live.
        // A full-screen transparent surface blocks all pointer input on Wayland;
        // restricting to top+right means the window surface covers only the
        // actual notification strip so the rest of the screen stays clickable.
        anchors { top: true; right: true }
        width: 360 + 32  // card width + left margin + right margin

        ListView {
            id: popupsList
            width: 360
            height: contentHeight  // shrinks/grows with the popup count
            spacing: 8
            model: shellRoot.popups
            interactive: false

            anchors {
                top: parent.top
                right: parent.right
                topMargin: 16
                rightMargin: 16
            }

            // Slide in from right + fade
            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "x"
                        from: 40; to: 0
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Slide out to right + fade
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "x"
                        to: 40
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                }
            }

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                required property var modelData
                width: ListView.view.width
                height: card.height

                NotificationCard {
                    id: card
                    width: parent.width
                    notif: parent.modelData
                    isPopup: true
                    onCloseClicked: shellRoot.removePopup(parent.modelData.id)
                    onActionClicked: (actionId) => shellRoot.invokeAction(parent.modelData.id, actionId)
                }
            }
        }
    }

    // ── History panel ────────────────────────────────────────────────────────────
    PanelWindow {
        id: historyWindow

        screen: popupWindow.screen

        visible: shellRoot.historyOpen
        color: "#99000000"

        WlrLayershell.namespace: "quickshell:notifications:history"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors { top: true; bottom: true; left: true; right: true }

        // Backdrop — click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.historyOpen = false
        }

        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.historyOpen = false
        }

        Rectangle {
            width: 400
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 16
            }
            color: "#1e1e2e"
            radius: 12
            border.color: "#313244"
            border.width: 1

            MouseArea { anchors.fill: parent; preventStealing: true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header: title left · "Clear all" pill right
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "󰂚  Notifications"
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        color: "#cdd6f4"
                        Layout.fillWidth: true
                    }

                    // Small "Clear all" pill — only visible when there are notifications
                    Rectangle {
                        visible: shellRoot.allNotifications.length > 0
                        height: 26
                        width: clearLabel.implicitWidth + 20
                        color: clearArea.containsMouse ? "#45475a" : "#313244"
                        radius: 13

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "Clear all"
                            color: "#a6adc8"
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: shellRoot.clearAllNotifications()
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                    opacity: 0.6
                }

                // Notification list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: shellRoot.allNotifications
                    boundsBehavior: Flickable.StopAtBounds

                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    }

                    remove: Transition {
                        NumberAnimation { property: "opacity"; to: 0; duration: 160; easing.type: Easing.InCubic }
                    }

                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
                    }

                    delegate: Item {
                        required property var modelData
                        width: ListView.view.width
                        height: card.height

                        NotificationCard {
                            id: card
                            width: parent.width
                            notif: parent.modelData
                            isPopup: false
                            onCloseClicked: shellRoot.removeNotification(parent.modelData.id)
                            onActionClicked: (actionId) => shellRoot.invokeAction(parent.modelData.id, actionId)
                        }
                    }

                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: "#6c7086"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        visible: parent.count === 0
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 3
                            radius: 1.5
                            color: "#585b70"
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }
}
