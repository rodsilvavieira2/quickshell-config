pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string inputText: ""
    property string outputText: ""
    property bool busy: false
    property string error: ""
    property int requestSerial: 0

    onInputTextChanged: scheduleTranslation()

    Connections {
        target: SidebarState

        function onProviderChanged() { root.scheduleTranslation(); }
        function onOllamaModelChanged() { if (SidebarState.provider === "ollama") root.scheduleTranslation(); }
        function onGeminiModelChanged() { if (SidebarState.provider === "gemini_cli") root.scheduleTranslation(); }
        function onOpenAiModelChanged() { if (SidebarState.provider === "openai_compatible") root.scheduleTranslation(); }
        function onOpenAiBaseUrlChanged() { if (SidebarState.provider === "openai_compatible") root.scheduleTranslation(); }
        function onOpenAiApiKeyChanged() { if (SidebarState.provider === "openai_compatible") root.scheduleTranslation(); }
        function onTranslatorSourceLanguageChanged() { root.scheduleTranslation(); }
        function onTranslatorTargetLanguageChanged() { root.scheduleTranslation(); }
        function onTranslatorDebounceMsChanged() {
            debounceTimer.interval = SidebarState.translatorDebounceMs;
            root.scheduleTranslation();
        }
    }

    Timer {
        id: debounceTimer
        interval: SidebarState.translatorDebounceMs
        repeat: false
        onTriggered: root.translateNow()
    }

    function clear() {
        root.inputText = "";
        root.outputText = "";
        root.error = "";
        root.busy = false;
        root.requestSerial += 1;
    }

    function swapLanguages() {
        const currentSource = SidebarState.translatorSourceLanguage;
        const currentTarget = SidebarState.translatorTargetLanguage;

        SidebarState.translatorSourceLanguage = currentTarget;
        SidebarState.translatorTargetLanguage = currentSource === "auto" ? "en" : currentSource;
    }

    function scheduleTranslation() {
        if (!Utils.trim(root.inputText).length) {
            root.outputText = "";
            root.error = "";
            root.busy = false;
            root.requestSerial += 1;
            debounceTimer.stop();
            return;
        }

        debounceTimer.restart();
    }

    function translateNow() {
        const text = Utils.trim(root.inputText);
        if (!text.length) {
            root.outputText = "";
            root.error = "";
            root.busy = false;
            return;
        }

        root.busy = true;
        root.error = "";
        const serial = ++root.requestSerial;

        if (SidebarState.provider === "gemini_cli") {
            requestGeminiCli(serial, text);
        } else if (SidebarState.provider === "openai_compatible") {
            requestOpenAi(serial, text);
        } else {
            requestOllama(serial, text);
        }
    }

    function translationPrompt(text) {
        const sourceLabel = LanguageCatalog.labelForCode(SidebarState.translatorSourceLanguage);
        const targetLabel = LanguageCatalog.labelForCode(SidebarState.translatorTargetLanguage);

        return [
            "Translate the text below.",
            `Source language: ${sourceLabel}.`,
            `Target language: ${targetLabel}.`,
            "Return only the translated text. Do not explain your work.",
            "",
            text
        ].join("\n");
    }

    function finish(serial, content) {
        if (serial !== root.requestSerial) return;
        root.busy = false;
        root.error = "";
        root.outputText = Utils.trim(content);
    }

    function fail(serial, message) {
        if (serial !== root.requestSerial) return;
        root.busy = false;
        root.error = message;
    }

    function requestOllama(serial, text) {
        Utils.requestJson(
            "http://127.0.0.1:11434/api/chat",
            "POST",
            { "Content-Type": "application/json" },
            {
                model: SidebarState.activeModel(),
                stream: false,
                messages: [
                    {
                        role: "system",
                        content: "You are a translation engine. Return only translated text."
                    },
                    {
                        role: "user",
                        content: translationPrompt(text)
                    }
                ]
            },
            response => {
                finish(serial, response?.message?.content ?? response?.response ?? "");
            },
            detail => {
                fail(serial, `Ollama translation failed: ${detail}`);
            }
        );
    }

    function requestOpenAi(serial, text) {
        const endpoint = Utils.openAiChatEndpoint(SidebarState.openAiBaseUrl);
        const apiKey = Utils.trim(SidebarState.openAiApiKey);

        if (!endpoint.length || !apiKey.length) {
            fail(serial, "OpenAI-compatible translation needs a base URL and API key.");
            return;
        }

        Utils.requestJson(
            endpoint,
            "POST",
            {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${apiKey}`
            },
            {
                model: SidebarState.activeModel(),
                temperature: 0.2,
                messages: [
                    {
                        role: "system",
                        content: "You are a translation engine. Return only translated text."
                    },
                    {
                        role: "user",
                        content: translationPrompt(text)
                    }
                ]
            },
            response => {
                const choice = response?.choices?.[0]?.message?.content;
                finish(serial, Utils.openAiContentToText(choice));
            },
            detail => {
                fail(serial, `OpenAI-compatible translation failed: ${detail}`);
            }
        );
    }

    function requestGeminiCli(serial, text) {
        geminiTranslateProc.serial = serial;
        geminiTranslateProc.stdoutBuffer = "";
        geminiTranslateProc.stderrBuffer = "";
        geminiTranslateProc.command = [
            "gemini",
            "--model", SidebarState.activeModel(),
            "--prompt", translationPrompt(text),
            "--output-format", "text"
        ];
        geminiTranslateProc.running = true;
    }

    Process {
        id: geminiTranslateProc

        property int serial: 0
        property string stdoutBuffer: ""
        property string stderrBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                geminiTranslateProc.stdoutBuffer += data + "\n";
            }
        }

        stderr: SplitParser {
            onRead: data => {
                geminiTranslateProc.stderrBuffer += data + "\n";
            }
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                finish(geminiTranslateProc.serial, geminiTranslateProc.stdoutBuffer);
            } else {
                const detail = Utils.trim(geminiTranslateProc.stderrBuffer) || "Gemini CLI exited with a non-zero status.";
                fail(geminiTranslateProc.serial, `Gemini CLI translation failed: ${detail}`);
            }
        }
    }
}
