import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../../common/widgets"
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Item {
    id: root
    implicitHeight: 46

    property alias text: field.text
    property alias input: field
    signal accepted()
    signal navigateUp()
    signal navigateDown()

    function forceFocus() {
        field.forceActiveFocus()
    }

    Component.onCompleted: forceFocus()

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Design.ThemePalette.withAlpha(
            Design.Tokens.color.surfaceContainerHighest,
            Design.ThemeSettings.isDark ? 0.76 : 0.92
        )
        border.width: 1
        border.color: field.activeFocus
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.34)
            : Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.72)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            DS.LucideIcon {
                name: "search"
                color: field.activeFocus
                    ? Design.Tokens.color.text.primary
                    : Design.Tokens.color.text.secondary
                iconSize: 17
                opticalScale: 0.95
                Layout.alignment: Qt.AlignVCenter
            }

            TextField {
                id: field
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: null
                color: Design.Tokens.color.text.primary
                selectedTextColor: Design.Tokens.color.text.inverse
                selectionColor: Design.Tokens.color.primary
                placeholderTextColor: Design.ThemePalette.withAlpha(Design.Tokens.color.text.secondary, 0.9)
                placeholderText: "Go"
                font.family: Design.Tokens.font.family.body
                font.pixelSize: Design.Tokens.font.size.body
                font.weight: Design.Tokens.font.weight.medium
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                onAccepted: root.accepted()
                Keys.onEscapePressed: event => {
                    GlobalStates.searchOpen = false
                    event.accepted = true
                }
                Keys.onUpPressed: event => {
                    root.navigateUp()
                    event.accepted = true
                }
                Keys.onDownPressed: event => {
                    root.navigateDown()
                    event.accepted = true
                }
            }
        }
    }
}
