import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS

DS.Card {
    id: root

    property string title: ""
    property string description: ""
    default property alias contentData: contentColumn.data
    Layout.fillWidth: true

    ColumnLayout {
        width: parent.width
        spacing: Design.Tokens.space.s16

        DS.HeaderBlock {
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
