pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell

Singleton {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/sidebar_left.ini"
    readonly property url settingsLocation: "file://" + settingsPath
    readonly property var providerOptions: [
        { label: "Ollama", value: "ollama" },
        { label: "Gemini CLI", value: "gemini_cli" },
        { label: "OpenAI Compatible", value: "openai_compatible" }
    ]

    property bool open: false
    property int currentTab: 0
    property string provider: "ollama"
    property string ollamaModel: "llama3.2:3b"
    property string geminiModel: "gemini-2.5-flash"
    property string openAiModel: "gpt-4.1-mini"
    property string openAiBaseUrl: "https://api.openai.com/v1"
    property string openAiApiKey: ""
    property string translatorSourceLanguage: "auto"
    property string translatorTargetLanguage: "pt"
    property int translatorDebounceMs: 420
    property bool ready: false

    readonly property bool usesOpenAiConfig: provider === "openai_compatible"

    Settings {
        id: persisted
        location: root.settingsLocation
        category: "sidebar-left"
    }

    Component.onCompleted: root.reload()

    onProviderChanged: saveValue("provider", provider)
    onOllamaModelChanged: saveValue("ollamaModel", ollamaModel)
    onGeminiModelChanged: saveValue("geminiModel", geminiModel)
    onOpenAiModelChanged: saveValue("openAiModel", openAiModel)
    onOpenAiBaseUrlChanged: saveValue("openAiBaseUrl", openAiBaseUrl)
    onOpenAiApiKeyChanged: saveValue("openAiApiKey", openAiApiKey)
    onTranslatorSourceLanguageChanged: saveValue("translatorSourceLanguage", translatorSourceLanguage)
    onTranslatorTargetLanguageChanged: saveValue("translatorTargetLanguage", translatorTargetLanguage)
    onTranslatorDebounceMsChanged: saveValue("translatorDebounceMs", translatorDebounceMs)
    onCurrentTabChanged: saveValue("currentTab", currentTab)

    function reload() {
        ready = false;
        persisted.sync();

        provider = readString("provider", provider);
        ollamaModel = readString("ollamaModel", ollamaModel);
        geminiModel = readString("geminiModel", geminiModel);
        openAiModel = readString("openAiModel", openAiModel);
        openAiBaseUrl = readString("openAiBaseUrl", openAiBaseUrl);
        openAiApiKey = readString("openAiApiKey", openAiApiKey);
        translatorSourceLanguage = readString("translatorSourceLanguage", translatorSourceLanguage);
        translatorTargetLanguage = readString("translatorTargetLanguage", translatorTargetLanguage);
        translatorDebounceMs = Math.max(120, Number(persisted.value("translatorDebounceMs", translatorDebounceMs)));
        currentTab = Math.max(0, Number(persisted.value("currentTab", currentTab)) || 0);

        ready = true;
    }

    function readString(key, fallback) {
        const value = persisted.value(key, fallback);
        const stringValue = value === undefined || value === null ? "" : String(value);
        return stringValue.length > 0 ? stringValue : fallback;
    }

    function saveValue(key, value) {
        if (!ready) return;
        persisted.setValue(key, value);
        persisted.sync();
    }

    function providerIndexForValue(value) {
        const index = providerOptions.findIndex(option => option.value === value);
        return index >= 0 ? index : 0;
    }

    function labelForProvider(value) {
        const option = providerOptions.find(entry => entry.value === value);
        return option ? option.label : "Provider";
    }

    function modelForProvider(providerId) {
        if (providerId === "gemini_cli") return geminiModel;
        if (providerId === "openai_compatible") return openAiModel;
        return ollamaModel;
    }

    function activeModel() {
        return modelForProvider(provider);
    }

    function setProviderByIndex(index) {
        if (index < 0 || index >= providerOptions.length) return;
        provider = providerOptions[index].value;
    }

    function setModelForProvider(providerId, model) {
        const cleaned = Utils.trim(model);
        if (!cleaned.length) return;

        if (providerId === "gemini_cli") {
            geminiModel = cleaned;
        } else if (providerId === "openai_compatible") {
            openAiModel = cleaned;
        } else {
            ollamaModel = cleaned;
        }
    }

    function setActiveModel(model) {
        setModelForProvider(provider, model);
    }
}
