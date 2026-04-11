import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Item {
    id: root

    function focusPrimaryInput() {
        inputArea.forceActiveFocus();
    }

    function syncInput() {
        if (inputArea.text !== TranslatorService.inputText) {
            inputArea.text = TranslatorService.inputText;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Design.Tokens.space.s12

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            DS.SelectField {
                id: sourceField
                Layout.fillWidth: true
                model: LanguageCatalog.languages
                onActivated: index => SidebarState.translatorSourceLanguage = model[index].value
            }

            DS.IconButton {
                preferredHeight: 40
                iconName: "chevron-right"
                onClicked: TranslatorService.swapLanguages()
            }

            DS.SelectField {
                id: targetField
                Layout.fillWidth: true
                model: LanguageCatalog.languages
                onActivated: index => SidebarState.translatorTargetLanguage = model[index].value
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            visible: TranslatorService.error.length > 0
            kind: "error"
            title: "Translation failed"
            message: TranslatorService.error
        }

        DS.Surface {
            Layout.fillWidth: true
            Layout.preferredHeight: 210
            variant: "surfaceContainerLow"
            padding: Design.Tokens.space.s12

            ColumnLayout {
                anchors.fill: parent
                spacing: Design.Tokens.space.s8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s8

                    Text {
                        Layout.fillWidth: true
                        text: `Translated to ${LanguageCatalog.labelForCode(SidebarState.translatorTargetLanguage)}`
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.label
                        font.pixelSize: Design.Tokens.font.size.label
                        font.weight: Design.Tokens.font.weight.semibold
                    }

                    DS.Button {
                        text: "Copy"
                        variant: "ghost"
                        preferredHeight: 34
                        disabled: !Utils.trim(TranslatorService.outputText).length
                        onClicked: Quickshell.clipboardText = TranslatorService.outputText
                    }
                }

                TextArea {
                    id: outputArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    readOnly: true
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    text: TranslatorService.outputText
                    placeholderText: TranslatorService.busy ? "Translating..." : "Translation appears here."
                    color: Design.Tokens.color.text.primary
                    selectedTextColor: Design.Tokens.color.text.inverse
                    selectionColor: Design.Tokens.color.primary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.body
                    leftPadding: Design.Tokens.space.s12
                    rightPadding: Design.Tokens.space.s12
                    topPadding: Design.Tokens.space.s8
                    bottomPadding: Design.Tokens.space.s8

                    background: Rectangle {
                        radius: Design.Tokens.shape.large
                        color: Design.Tokens.color.surface
                        border.width: Design.Tokens.border.width.thin
                        border.color: Design.Tokens.color.outlineVariant
                    }
                }
            }
        }

        DS.Surface {
            Layout.fillWidth: true
            Layout.fillHeight: true
            variant: "surfaceContainerHigh"
            padding: Design.Tokens.space.s12

            ColumnLayout {
                anchors.fill: parent
                spacing: Design.Tokens.space.s8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s8

                    Text {
                        Layout.fillWidth: true
                        text: `Source: ${LanguageCatalog.labelForCode(SidebarState.translatorSourceLanguage)}`
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.label
                        font.pixelSize: Design.Tokens.font.size.label
                        font.weight: Design.Tokens.font.weight.semibold
                    }

                    DS.Button {
                        text: "Paste"
                        variant: "ghost"
                        preferredHeight: 34
                        onClicked: TranslatorService.inputText = Quickshell.clipboardText
                    }

                    DS.Button {
                        text: "Clear"
                        variant: "ghost"
                        preferredHeight: 34
                        disabled: !Utils.trim(TranslatorService.inputText).length
                        onClicked: TranslatorService.clear()
                    }
                }

                TextArea {
                    id: inputArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextArea.Wrap
                    placeholderText: "Type text to translate..."
                    color: Design.Tokens.color.text.primary
                    selectedTextColor: Design.Tokens.color.text.inverse
                    selectionColor: Design.Tokens.color.primary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.body
                    leftPadding: Design.Tokens.space.s12
                    rightPadding: Design.Tokens.space.s12
                    topPadding: Design.Tokens.space.s8
                    bottomPadding: Design.Tokens.space.s8

                    background: Rectangle {
                        radius: Design.Tokens.shape.large
                        color: Design.Tokens.color.surface
                        border.width: Design.Tokens.border.width.thin
                        border.color: inputArea.activeFocus ? Design.Tokens.color.focusRing : Design.Tokens.color.outlineVariant
                    }

                    onTextChanged: {
                        if (text !== TranslatorService.inputText) {
                            TranslatorService.inputText = text;
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: SidebarState

        function onTranslatorSourceLanguageChanged() {
            sourceField.currentIndex = LanguageCatalog.indexForCode(SidebarState.translatorSourceLanguage);
        }

        function onTranslatorTargetLanguageChanged() {
            targetField.currentIndex = LanguageCatalog.indexForCode(SidebarState.translatorTargetLanguage);
        }
    }

    Connections {
        target: TranslatorService

        function onInputTextChanged() {
            root.syncInput();
        }
    }

    Component.onCompleted: {
        root.syncInput();
        sourceField.currentIndex = LanguageCatalog.indexForCode(SidebarState.translatorSourceLanguage);
        targetField.currentIndex = LanguageCatalog.indexForCode(SidebarState.translatorTargetLanguage);
    }
}
