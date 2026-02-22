import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."
import "../../services"

MouseArea {
    id: root
    property var notificationGroup
    property var notifications: notificationGroup ? (notificationGroup.notifications !== undefined ? notificationGroup.notifications : []) : []
    property int notificationCount: notifications.length
    property bool multipleNotifications: notificationCount > 1
    property bool expanded: false
    property bool popup: false
    property real padding: 10
    implicitHeight: background.implicitHeight

    property real dragConfirmThreshold: 70
    property real dismissOvershoot: 20
    property var qmlParent: root.parent ? root.parent.parent : null
    property var parentDragIndex: qmlParent ? (qmlParent.dragIndex !== undefined ? qmlParent.dragIndex : -1) : -1
    property var parentDragDistance: qmlParent ? (qmlParent.dragDistance !== undefined ? qmlParent.dragDistance : 0) : 0
    property var dragIndexDiff: Math.abs(parentDragIndex - index)
    property real xOffset: dragIndexDiff == 0 ? parentDragDistance :
        Math.abs(parentDragDistance) > dragConfirmThreshold ? 0 :
        dragIndexDiff == 1 ? (parentDragDistance * 0.3) :
        dragIndexDiff == 2 ? (parentDragDistance * 0.1) : 0

    function destroyWithAnimation(left = false) {
        if (root.qmlParent)
            root.qmlParent.resetDrag()
        background.anchors.leftMargin = background.anchors.leftMargin
        destroyAnimation.left = left
        destroyAnimation.running = true
    }

    hoverEnabled: true
    onContainsMouseChanged: {
        if (!root.popup) return
        if (root.containsMouse) root.notifications.forEach(notif => {
            Notifications.cancelTimeout(notif.notificationId)
        })
        else root.notifications.forEach(notif => {
            Notifications.timeoutNotification(notif.notificationId)
        })
    }

    SequentialAnimation {
        id: destroyAnimation
        property bool left: true
        running: false

        NumberAnimation {
            target: background.anchors
            property: "leftMargin"
            to: (root.width + root.dismissOvershoot) * (destroyAnimation.left ? -1 : 1)
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        onFinished: () => {
            root.notifications.forEach((notif) => {
                Qt.callLater(() => {
                    Notifications.discardNotification(notif.notificationId)
                })
            })
        }
    }

    function toggleExpanded() {
        if (expanded) implicitHeightAnim.enabled = true
        else implicitHeightAnim.enabled = false
        root.expanded = !root.expanded
    }

    DragManager {
        id: dragManager
        anchors.fill: parent
        interactive: !expanded
        automaticallyReset: false
        acceptedButtonsMask: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onDragPressed: (mouse) => {
            if (mouse.button === Qt.RightButton)
                root.toggleExpanded()
        }

        onDragClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton)
                root.destroyWithAnimation()
        }

        onDraggingChanged: () => {
            if (dragging && root.qmlParent) {
                root.qmlParent.dragIndex = root.index !== undefined ? root.index : root.parent.children.indexOf(root)
            }
        }

        onDragDiffXChanged: () => {
            if (root.qmlParent)
                root.qmlParent.dragDistance = dragDiffX
        }

        onDragReleased: (diffX, diffY) => {
            if (Math.abs(diffX) > root.dragConfirmThreshold)
                root.destroyWithAnimation(diffX < 0)
            else
                dragManager.resetDrag()
        }
    }

    StyledRectangularShadow {
        target: background
        visible: popup
    }

    Rectangle {
        id: background
        anchors.left: parent.left
        width: parent.width
        color: popup ? Appearance.colors.colSurface : Appearance.colors.colLayer2
        radius: Appearance.rounding.normal
        anchors.leftMargin: root.xOffset

        Behavior on anchors.leftMargin {
            enabled: !dragManager.dragging
            NumberAnimation {
                duration: Appearance.animation.elementMove.duration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }

        clip: true
        implicitHeight: root.expanded ?
            row.implicitHeight + padding * 2 :
            Math.min(86, row.implicitHeight + padding * 2)

        Behavior on implicitHeight {
            id: implicitHeightAnim
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        RowLayout {
            id: row
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            spacing: 10

            NotificationAppIcon {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: false
                image: root.multipleNotifications ? "" : (notificationGroup ? (notificationGroup.notifications[0] ? notificationGroup.notifications[0].image : "") : "")
                appIcon: notificationGroup ? notificationGroup.appIcon : ""
                summary: notificationGroup ? (notificationGroup.notifications[root.notificationCount - 1] ? notificationGroup.notifications[root.notificationCount - 1].summary : "") : ""
                urgency: root.notifications.some(n => n.urgency === NotificationUrgency.Critical.toString()) ?
                    NotificationUrgency.Critical : NotificationUrgency.Normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: expanded ? (root.multipleNotifications ?
                    (notificationGroup ? ((notificationGroup.notifications[root.notificationCount - 1] ? notificationGroup.notifications[root.notificationCount - 1].image : "") != "") : false) ? 35 :
                    6 : 0) : 0
                Behavior on spacing {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Layout.minimumWidth: 0

                Item {
                    id: topRow
                    Layout.fillWidth: true
                    property real fontSize: Appearance.font.pixelSize.smaller
                    property bool showAppName: root.multipleNotifications
                    implicitHeight: Math.max(topTextRow.implicitHeight, expandButton.implicitHeight)

                    RowLayout {
                        id: topTextRow
                        anchors.left: parent.left
                        anchors.right: expandButton.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        StyledText {
                            id: appName
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: topRow.showAppName ?
                                (notificationGroup ? notificationGroup.appName : "") :
                                (notificationGroup ? (notificationGroup.notifications[0] ? notificationGroup.notifications[0].summary : "") : "")
                            font.pixelSize: topRow.showAppName ?
                                topRow.fontSize :
                                Appearance.font.pixelSize.small
                            color: topRow.showAppName ?
                                Appearance.colors.colSubtext :
                                Appearance.colors.colOnLayer0
                        }
                        StyledText {
                            id: timeText
                            Layout.rightMargin: 10
                            Layout.fillWidth: false
                            horizontalAlignment: Text.AlignLeft
                            text: NotificationUtils.getFriendlyNotifTimeString(notificationGroup ? notificationGroup.time : 0)
                            font.pixelSize: topRow.fontSize
                            color: Appearance.colors.colSubtext
                        }
                    }
                    NotificationGroupExpandButton {
                        id: expandButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        count: root.notificationCount
                        expanded: root.expanded
                        fontSize: topRow.fontSize
                        onClicked: { root.toggleExpanded() }

                        StyledToolTip {
                            text: "Tip: right-clicking a group\nalso expands it"
                        }
                    }
                }

                StyledListView {
                    id: notificationsColumn
                    implicitHeight: contentHeight
                    Layout.fillWidth: true
                    spacing: expanded ? 6 : 4
                    interactive: false
                    clip: true
                    Behavior on spacing {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    model: ScriptModel {
                        values: root.expanded ? root.notifications.slice().reverse() :
                            root.notifications.slice().reverse().slice(0, 2)
                    }
                    delegate: NotificationItem {
                        required property int index
                        required property var modelData
                        notificationObject: modelData
                        expanded: root.expanded
                        onlyNotification: (root.notificationCount === 1)
                        width: parent ? parent.width : implicitWidth
                        opacity: (!root.expanded && index == 1 && root.notificationCount > 2) ? 0.5 : 1
                        visible: root.expanded || (index < 2)
                    }
                }
            }
        }
    }
}
