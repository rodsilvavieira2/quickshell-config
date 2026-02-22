import QtQuick
import Quickshell
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

    Image {
        id: appIconImage
        visible: root.image === "" && root.appIcon !== ""
        anchors.centerIn: parent
        width: 24
        height: 24
        source: root.appIcon.startsWith("/") || root.appIcon.startsWith("file:") || root.appIcon.startsWith("qrc:")
            ? root.appIcon
            : Quickshell.iconPath(root.appIcon, "image-missing")
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
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
