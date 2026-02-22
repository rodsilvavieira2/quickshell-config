import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."
import "../../services"

Item {
    id: root
    clip: true
    property var notificationObject
    property bool expanded: false
    property bool onlyNotification: false
    property real fontSize: Appearance.font.pixelSize.small
    property real padding: onlyNotification ? 0 : 8
    property real summaryElideRatio: 0.85
    property var notificationActions: notificationObject ? (notificationObject.actions !== undefined ? notificationObject.actions : []) : []

    property real dragConfirmThreshold: 70
    property real dismissOvershoot: notificationIcon.implicitWidth + 20
    property var qmlParent: root.parent ? root.parent.parent : null
    property var parentDragIndex: qmlParent ? (qmlParent.dragIndex !== undefined ? qmlParent.dragIndex : -1) : -1
    property var parentDragDistance: qmlParent ? (qmlParent.dragDistance !== undefined ? qmlParent.dragDistance : 0) : 0
    property var dragIndexDiff: Math.abs(parentDragIndex - index)
    property real xOffset: dragIndexDiff == 0 ? parentDragDistance :
        Math.abs(parentDragDistance) > dragConfirmThreshold ? 0 :
        dragIndexDiff == 1 ? (parentDragDistance * 0.3) :
        dragIndexDiff == 2 ? (parentDragDistance * 0.1) : 0

    implicitHeight: background.implicitHeight

    function destroyWithAnimation(left = false) {
        if (root.qmlParent)
            root.qmlParent.resetDrag()
        background.anchors.leftMargin = background.anchors.leftMargin
        destroyAnimation.left = left
        destroyAnimation.running = true
    }

    TextMetrics {
        id: summaryTextMetrics
        font.pixelSize: root.fontSize
                    text: root.notificationObject ? (root.notificationObject.summary !== undefined ? root.notificationObject.summary : "") : ""
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
            if (notificationObject)
                Notifications.discardNotification(notificationObject.notificationId)
        }
    }

    DragManager {
        id: dragManager
        anchors.fill: root
        interactive: expanded
        automaticallyReset: false
        acceptedButtonsMask: Qt.LeftButton | Qt.MiddleButton

        onDragClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                root.destroyWithAnimation()
            }
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

    Rectangle {
        id: background
        width: parent.width
        anchors.left: parent.left
        radius: Appearance.rounding.small
        anchors.leftMargin: root.xOffset
        clip: true

        Behavior on anchors.leftMargin {
            enabled: !dragManager.dragging
            NumberAnimation {
                duration: Appearance.animation.elementMove.duration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }

        color: (expanded && !onlyNotification) ?
            (notificationObject ? notificationObject.urgency : NotificationUrgency.Normal) == NotificationUrgency.Critical ?
                ColorUtils.mix(Appearance.colors.colCritical, Appearance.colors.colLayer2, 0.35) :
                Appearance.colors.colLayer2 :
            ColorUtils.transparentize(Appearance.colors.colLayer2, 0.3)

        implicitHeight: expanded ? (contentColumn.implicitHeight + padding * 2) : summaryRow.implicitHeight
        Behavior on implicitHeight {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }

        NotificationAppIcon {
            id: notificationIcon
            opacity: (!onlyNotification && (notificationObject ? notificationObject.image : "") != "" && expanded) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            image: notificationObject ? (notificationObject.image !== undefined ? notificationObject.image : "") : ""
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: root.padding
            anchors.topMargin: root.padding
            appIcon: notificationObject ? (notificationObject.appIcon !== undefined ? notificationObject.appIcon : "") : ""
            summary: notificationObject ? (notificationObject.summary !== undefined ? notificationObject.summary : "") : ""
            urgency: notificationObject ? (notificationObject.urgency !== undefined ? notificationObject.urgency : NotificationUrgency.Normal) : NotificationUrgency.Normal
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: expanded ? (notificationIcon.visible ? notificationIcon.implicitWidth + root.padding * 2 : root.padding) : 0
            anchors.rightMargin: expanded ? root.padding : 0
            anchors.topMargin: expanded ? root.padding : 0
            anchors.bottomMargin: expanded ? root.padding : 0
            spacing: 3

            Behavior on anchors.margins {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            RowLayout {
                id: summaryRow
                visible: !root.onlyNotification || !root.expanded
                Layout.fillWidth: true
                implicitHeight: summaryText.implicitHeight
                StyledText {
                    id: summaryText
                    Layout.fillWidth: summaryTextMetrics.width >= summaryRow.implicitWidth * root.summaryElideRatio
                    Layout.minimumWidth: 0
                    visible: !root.onlyNotification
                    font.pixelSize: root.fontSize
                    color: Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                    text: root.notificationObject ? (root.notificationObject.summary !== undefined ? root.notificationObject.summary : "") : ""
                }
                StyledText {
                    opacity: !root.expanded ? 1 : 0
                    visible: opacity > 0
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    font.pixelSize: root.fontSize
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    maximumLineCount: 1
                    textFormat: Text.StyledText
                    text: {
                        return NotificationUtils.processNotificationBody(notificationObject ? (notificationObject.body !== undefined ? notificationObject.body : "") : "", notificationObject ? (notificationObject.appName !== undefined ? notificationObject.appName : (notificationObject.summary !== undefined ? notificationObject.summary : "")) : "").replace(/\n/g, "<br/>")
                    }
                }
            }

            ColumnLayout {
                id: expandedContentColumn
                Layout.fillWidth: true
                opacity: root.expanded ? 1 : 0
                visible: opacity > 0

                StyledText {
                    id: notificationBodyText
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    Layout.fillWidth: true
                    font.pixelSize: root.fontSize
                    color: Appearance.colors.colSubtext
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    textFormat: Text.RichText
                    text: {
                        return `<style>img{max-width:${expandedContentColumn.width}px;}</style>` +
                            `${NotificationUtils.processNotificationBody(notificationObject ? (notificationObject.body !== undefined ? notificationObject.body : "") : "", notificationObject ? (notificationObject.appName !== undefined ? notificationObject.appName : (notificationObject.summary !== undefined ? notificationObject.summary : "")) : "").replace(/\n/g, "<br/>")}`
                    }

                    onLinkActivated: (link) => {
                        Qt.openUrlExternally(link)
                        GlobalStates.panelOpen = false
                    }

                    PointingHandLinkHover {}
                }

                Rectangle {
                    color: "transparent"
                    Layout.fillWidth: true
                    implicitWidth: actionsFlickable.implicitWidth
                    implicitHeight: actionsFlickable.implicitHeight

                    clip: true
                    radius: Appearance.rounding.small

                    Behavior on implicitWidth {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }

                    ScrollEdgeFade {
                        target: actionsFlickable
                        vertical: false
                    }

                    StyledFlickable {
                        id: actionsFlickable
                        anchors.fill: parent
                        implicitHeight: actionRowLayout.implicitHeight
                        contentWidth: actionRowLayout.implicitWidth
                        contentHeight: actionRowLayout.implicitHeight
                        contentX: 0
                        contentY: 0
                        interactive: actionRowLayout.implicitWidth > width
                        flickableDirection: Flickable.HorizontalFlick

                        Behavior on opacity {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        Behavior on height {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        Behavior on implicitHeight {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }

                        RowLayout {
                            id: actionRowLayout
                            Layout.alignment: Qt.AlignBottom
                            spacing: 6

                            NotificationActionButton {
                                id: closeBtn
                                Layout.fillWidth: true
                                buttonText: "Close"
                                urgency: notificationObject ? (notificationObject.urgency !== undefined ? notificationObject.urgency : NotificationUrgency.Normal) : NotificationUrgency.Normal
                                implicitWidth: (notificationActions.length == 0) ? ((actionsFlickable.width - actionRowLayout.spacing) / 2) :
                                    Math.min(contentItem.implicitWidth + leftPadding + rightPadding, actionsFlickable.width * 0.8)

                                onClicked: {
                                    root.destroyWithAnimation()
                                }

                                contentItem: Item {
                                    implicitWidth: Appearance.font.pixelSize.larger
                                    implicitHeight: Appearance.font.pixelSize.larger
                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        iconSize: Appearance.font.pixelSize.larger
                                        color: closeBtn.highlighted ? closeBtn.colTextHover : closeBtn.colText
                                        text: "close"
                                        Behavior on color {
                                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                        }
                                    }
                                }
                            }

                            Repeater {
                                id: actionRepeater
                                model: notificationActions
                                NotificationActionButton {
                                    id: notifAction
                                    required property var modelData
                                    Layout.fillWidth: true
                                    buttonText: modelData.text
                                    urgency: notificationObject ? (notificationObject.urgency !== undefined ? notificationObject.urgency : NotificationUrgency.Normal) : NotificationUrgency.Normal
                                    onClicked: {
                                        if (notificationObject)
                                            Notifications.attemptInvokeAction(notificationObject.notificationId, modelData.identifier)
                                    }
                                }
                            }

                            NotificationActionButton {
                                id: copyBtn
                                Layout.fillWidth: true
                                urgency: notificationObject ? (notificationObject.urgency !== undefined ? notificationObject.urgency : NotificationUrgency.Normal) : NotificationUrgency.Normal
                                implicitWidth: (notificationActions.length == 0) ? ((actionsFlickable.width - actionRowLayout.spacing) / 2) :
                                    Math.min(contentItem.implicitWidth + leftPadding + rightPadding, actionsFlickable.width * 0.8)

                                onClicked: {
                                    Quickshell.clipboardText = notificationObject ? (notificationObject.body !== undefined ? notificationObject.body : "") : ""
                                    copyIcon.text = "inventory"
                                    copyIconTimer.restart()
                                }

                                Timer {
                                    id: copyIconTimer
                                    interval: 1500
                                    repeat: false
                                    onTriggered: {
                                        copyIcon.text = "content_copy"
                                    }
                                }

                                contentItem: Item {
                                    implicitWidth: Appearance.font.pixelSize.larger
                                    implicitHeight: Appearance.font.pixelSize.larger
                                    MaterialSymbol {
                                        id: copyIcon
                                        anchors.centerIn: parent
                                        iconSize: Appearance.font.pixelSize.larger
                                        color: copyBtn.highlighted ? copyBtn.colTextHover : copyBtn.colText
                                        text: "content_copy"
                                        Behavior on color {
                                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
