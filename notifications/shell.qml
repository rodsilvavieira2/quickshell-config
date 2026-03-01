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

    IpcHandler {
        target: "notifications"
        function toggle() { shellRoot.historyOpen = !shellRoot.historyOpen; }
        function open() { shellRoot.historyOpen = true; }
        function close() { shellRoot.historyOpen = false; }
        function clear() { 
            notifServer.trackedNotifications.values.forEach(n => n.dismiss());
            shellRoot.allNotifications = [];
            shellRoot.popups = [];
            
            for (let id in shellRoot.popupTimers) {
                shellRoot.popupTimers[id].destroy();
            }
            shellRoot.popupTimers = {};
        }
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
                let t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + timeout + '; running: true; onTriggered: shellRoot.removePopup(' + n.id + ') }', shellRoot);
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

    PanelWindow {
        id: popupWindow
        
        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i];
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }
        
        visible: shellRoot.popups.length > 0 && !shellRoot.historyOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:notifications:popups"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            right: true
            bottom: true
        }
        margins {
            top: 20
            right: 20
        }
        
        implicitWidth: 380

        ListView {
            id: popupsList
            anchors.fill: parent
            spacing: 12
            model: shellRoot.popups
            interactive: false
            
            delegate: NotificationCard {
                notif: modelData
                isPopup: true
                onCloseClicked: shellRoot.removePopup(modelData.id)
                onActionClicked: (actionId) => shellRoot.invokeAction(modelData.id, actionId)
            }
        }
    }

    PanelWindow {
        id: historyWindow
        
        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: popupWindow.screen
        
        visible: shellRoot.historyOpen
        color: "#66000000"

        WlrLayershell.namespace: "quickshell:notifications:history"
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
            onClicked: shellRoot.historyOpen = false
        }
        
        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.historyOpen = false
        }

        Rectangle {
            width: 420
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 20
            }
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2
            
            MouseArea { anchors.fill: parent; preventStealing: true }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "󰂚 Notifications"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        color: "#cdd6f4"
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Clear All"
                        font.pixelSize: 13
                        background: Rectangle { color: "#313244"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#cdd6f4"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                        onClicked: shellRoot.clear()
                    }
                    
                    Button {
                        text: "Close"
                        font.pixelSize: 13
                        background: Rectangle { color: "#f38ba8"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#1e1e2e"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                        onClicked: shellRoot.historyOpen = false
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#313244"
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 12
                    model: shellRoot.allNotifications
                    
                    delegate: NotificationCard {
                        width: ListView.view.width
                        notif: modelData
                        isPopup: false
                        onCloseClicked: shellRoot.removeNotification(modelData.id)
                        onActionClicked: (actionId) => shellRoot.invokeAction(modelData.id, actionId)
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: "#a6adc8"
                        font.pixelSize: 16
                        visible: parent.count === 0
                    }
                }
            }
        }
    }
}
