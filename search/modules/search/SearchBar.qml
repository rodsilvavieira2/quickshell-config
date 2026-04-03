import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/widgets"
import "../../services"
import "../../shared/ui" as DS

Item {
    id: root
    implicitHeight: field.implicitHeight + 22

    property alias text: field.text
    property alias input: field.inputField
    signal accepted()
    signal navigateUp()
    signal navigateDown()

    function forceFocus() {
        field.forceFocus()
    }

    Component.onCompleted: forceFocus()

    DS.SearchBar {
        id: field
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 12
        placeholderText: "Search apps and actions"
        onAccepted: root.accepted()
        onEscapePressed: {
            GlobalStates.searchOpen = false
        }
        onUpPressed: {
            root.navigateUp()
        }
        onDownPressed: {
            root.navigateDown()
        }
    }
}
