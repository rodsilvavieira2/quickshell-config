import QtQuick
import QtQuick.Effects

import ".." as Root

Item {
    id: root

    property url source: ""
    property color color: Root.Config.text
    property int iconSize: 16

    implicitWidth: iconSize
    implicitHeight: iconSize
    visible: source.toString().length > 0

    Image {
        id: iconSource
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: iconSource
        colorization: 1.0
        colorizationColor: root.color
    }
}
