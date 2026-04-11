import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

DS.Surface {
    id: root

    variant: "surfaceContainerLow"
    padding: Design.Tokens.space.s12

    readonly property bool missingOpenAiConfig: SidebarState.usesOpenAiConfig
        && (!Utils.trim(SidebarState.openAiBaseUrl).length || !Utils.trim(SidebarState.openAiApiKey).length)
    readonly property string helperText: {
        if (SidebarState.provider === "gemini_cli") {
            return "Uses the installed gemini CLI in headless mode.";
        }
        if (SidebarState.provider === "openai_compatible") {
            return "Base URL can point to OpenAI or any OpenAI-compatible /chat/completions endpoint.";
        }
        return "Requires an Ollama daemon listening on http://127.0.0.1:11434.";
    }

    function syncFields() {
        providerField.currentIndex = SidebarState.providerIndexForValue(SidebarState.provider);
        modelField.text = SidebarState.activeModel();
        baseUrlField.text = SidebarState.openAiBaseUrl;
        apiKeyField.text = SidebarState.openAiApiKey;
    }

    Component.onCompleted: syncFields()

    Connections {
        target: SidebarState

        function onProviderChanged() { root.syncFields(); }
        function onOllamaModelChanged() { root.syncFields(); }
        function onGeminiModelChanged() { root.syncFields(); }
        function onOpenAiModelChanged() { root.syncFields(); }
        function onOpenAiBaseUrlChanged() { root.syncFields(); }
        function onOpenAiApiKeyChanged() { root.syncFields(); }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Design.Tokens.space.s8

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8

            Text {
                Layout.fillWidth: true
                text: "Runtime"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.label
                font.weight: Design.Tokens.font.weight.semibold
            }

            DS.Chip {
                text: SidebarState.labelForProvider(SidebarState.provider)
                selected: true
            }
        }

        Text {
            text: "Provider"
            color: Design.Tokens.color.text.secondary
            font.family: Design.Tokens.font.family.label
            font.pixelSize: Design.Tokens.font.size.caption
        }

        DS.SelectField {
            id: providerField
            Layout.fillWidth: true
            model: SidebarState.providerOptions
            onActivated: index => SidebarState.setProviderByIndex(index)
        }

        Text {
            text: "Model"
            color: Design.Tokens.color.text.secondary
            font.family: Design.Tokens.font.family.label
            font.pixelSize: Design.Tokens.font.size.caption
        }

        DS.TextField {
            id: modelField
            Layout.fillWidth: true
            placeholderText: "Enter the model id"
            onTextEdited: SidebarState.setActiveModel(text)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s8
            visible: SidebarState.usesOpenAiConfig

            Text {
                text: "Base URL"
                color: Design.Tokens.color.text.secondary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.caption
            }

            DS.TextField {
                id: baseUrlField
                Layout.fillWidth: true
                placeholderText: "https://api.openai.com/v1"
                onTextEdited: SidebarState.openAiBaseUrl = text
            }

            Text {
                text: "API key"
                color: Design.Tokens.color.text.secondary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.caption
            }

            DS.TextField {
                id: apiKeyField
                Layout.fillWidth: true
                placeholderText: "sk-..."
                echoMode: TextInput.Password
                onTextEdited: SidebarState.openAiApiKey = text
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            kind: root.missingOpenAiConfig ? "warning" : "info"
            title: root.missingOpenAiConfig ? "Missing OpenAI-compatible settings" : "Backend note"
            message: root.missingOpenAiConfig
                ? "Fill in both the base URL and API key before sending requests with this provider."
                : root.helperText
        }
    }
}
