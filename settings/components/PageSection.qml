import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS

Item {
    id: root

    property string title: ""
    property string description: ""
    default property alias contentData: contentColumn.data
    Layout.fillWidth: true
    implicitHeight: sectionColumn.implicitHeight

    ColumnLayout {
        id: sectionColumn
        width: root.width
        spacing: Design.Tokens.space.s12

        DS.HeaderBlock {
            visible: root.title !== "" || root.description !== ""
            Layout.fillWidth: true
            title: root.title
            subtitle: root.description
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12
        }
    }
}
