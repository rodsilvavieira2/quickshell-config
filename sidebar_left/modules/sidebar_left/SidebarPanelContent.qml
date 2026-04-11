import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Item {
    id: root

    function focusCurrentTab() {
        const page = contentStack.currentItem;
        if (page && page.focusPrimaryInput) {
            page.focusPrimaryInput();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Design.Tokens.space.s16
        spacing: Design.Tokens.space.s12

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "Left Sidebar"
                    color: Design.Tokens.color.text.secondary
                    font.family: Design.Tokens.font.family.label
                    font.pixelSize: Design.Tokens.font.size.caption
                    font.weight: Design.Tokens.font.weight.medium
                }

                Text {
                    text: "Workspace Assistant"
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.title
                    font.pixelSize: Design.Tokens.font.size.title
                    font.weight: Design.Tokens.font.weight.semibold
                }
            }

            DS.IconButton {
                iconName: "x"
                preferredHeight: 38
                onClicked: SidebarState.open = false
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            DS.SegmentedButton {
                Layout.fillWidth: true
                text: "Intelligence"
                selected: SidebarState.currentTab === 0
                onClicked: SidebarState.currentTab = 0
            }

            DS.SegmentedButton {
                Layout.fillWidth: true
                text: "Translator"
                selected: SidebarState.currentTab === 1
                onClicked: SidebarState.currentTab = 1
            }
        }

        ProviderConfigCard {
            Layout.fillWidth: true
        }

        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: SidebarState.currentTab

            AiChatTab {}
            TranslatorTab {}
        }
    }
}
