import QtQuick

import ".." as Root

Item {
    id: root
    
    property string timeString: ""
    
    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
        Component.onCompleted: updateTime()
    }

    function updateTime() {
        var d = new Date();
        var h = d.getHours();
        var m = d.getMinutes();
        var ampm = h >= 12 ? "PM" : "AM";
        h = h % 12;
        if (h === 0) h = 12;
        var hStr = h < 10 ? "0" + h : "" + h;
        var mStr = m < 10 ? "0" + m : "" + m;
        root.timeString = hStr + ":" + mStr + " " + ampm;
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ""
            color: Root.Config.blue
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Root.Config.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.timeString
            color: Root.Config.text
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
