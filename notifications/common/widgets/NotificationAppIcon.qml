import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import ".."

Item {
    id: root
    property var appIcon: ""
    property var summary: ""
    property var urgency: NotificationUrgency.Normal
    property var image: ""
    property bool isUrgent: urgency === NotificationUrgency.Critical

    implicitWidth: 38
    implicitHeight: 38

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Appearance.rounding.full
        color: root.isUrgent ? Appearance.colors.colCritical : Appearance.colors.colLayer2
    }

    Loader {
        id: imageLoader
        active: root.image !== ""
        anchors.fill: parent
        sourceComponent: Rectangle {
            id: notifImage
            anchors.fill: parent
            clip: true
            layer.enabled: false
            radius: Appearance.rounding.full

            Image {
                anchors.fill: parent
                source: root.image
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }
    }

    Loader {
        id: appIconLoader
        active: root.image === "" && root.appIcon !== ""
        anchors.centerIn: parent
        sourceComponent: IconImage {
            implicitSize: 24
            asynchronous: true
            source: Quickshell.iconPath(root.appIcon, "image-missing")
        }
    }

    Loader {
        id: fallbackIcon
        active: root.image === "" && root.appIcon === ""
        anchors.fill: parent
        sourceComponent: MaterialSymbol {
            text: root.isUrgent ? "priority_high" : "notifications"
            iconSize: 20
            color: Appearance.colors.colOnLayer0
        }
    }
}
