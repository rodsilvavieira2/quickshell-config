import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool panelVisible: false
    property string backendHost: "127.0.0.1"
    property int backendPort: 18456
    property string backendUrl: "http://" + backendHost + ":" + backendPort
    property string backendScriptPath: "/home/rodrigo/.config/quickshell/translate/backend/app.py"
    property string preferredDefaultModel: "gemma4:e2b"

    property var models: []
    property string activeModel: ""
    property string modelState: "loading"
    property string modelMessage: "Checking Ollama..."
    property string modelError: ""
    property bool ollamaAvailable: false
    property bool backendAvailable: false

    property bool zenityAvailable: false
    property bool wlPasteAvailable: false
    property bool wlCopyAvailable: false
    property bool grimAvailable: false
    property bool slurpAvailable: false
    property bool tesseractAvailable: false
    property bool pwRecordAvailable: false
    property bool spdSayAvailable: false
    property bool espeakAvailable: false

    readonly property bool filePickerAvailable: zenityAvailable
    readonly property bool clipboardAvailable: wlPasteAvailable && wlCopyAvailable
    readonly property bool screenshotAvailable: grimAvailable && slurpAvailable
    readonly property bool ocrAvailable: tesseractAvailable
    readonly property bool audioCaptureAvailable: pwRecordAvailable
    readonly property bool speechAvailable: spdSayAvailable || espeakAvailable

    property bool translating: false
    property string translatedText: ""
    property string translationError: ""
    property double lastTranslatedAt: 0
    property string lastSourceText: ""
    property string lastSourceLanguage: "Auto"
    property string lastTargetLanguage: "Portuguese (Brazil)"
    property string lastTranslationModel: ""

    property string selectedImagePath: ""
    property string extractedText: ""
    property string ocrState: "idle"
    property string ocrMessage: "Upload or capture an image to continue."

    property bool recording: false
    property string recordedAudioPath: ""
    property string audioState: "idle"
    property string audioMessage: "Choose an audio source to start a live capture session."
    property string transcriptSource: ""
    property string transcriptTarget: ""
    property var audioSources: []
    property string selectedAudioSourceId: ""
    property string selectedAudioSourceName: ""
    property string selectedAudioSourceType: ""
    property string audioSessionId: ""
    property string audioSourcePayload: ""
    property string audioStartPayload: ""
    property string audioStopPayload: ""

    property string pendingSourceText: ""
    property string pendingSourceLanguage: "Auto"
    property string pendingTargetLanguage: "Portuguese (Brazil)"
    property string translationPayload: ""
    property string warmupPayload: ""
    property string clipboardPayload: ""
    property string ocrLanguageCode: ""
    property bool capabilitiesLoaded: false
    property string pendingModelSelection: ""

    signal feedback(string kind, string title, string message)
    signal translationCompleted(string sourceText, string translatedText, string sourceLanguage, string targetLanguage)
    signal clipboardTextReady(string text)
    signal ocrCompleted(string text)

    function normalizedAudioSources(nextSources) {
        if (!Array.isArray(nextSources)) {
            return [];
        }

        return nextSources.filter(source => source && source.id && source.name && source.is_available !== false);
    }

    function selectedAudioSource() {
        for (let index = 0; index < root.audioSources.length; index += 1) {
            const source = root.audioSources[index];
            if (String(source.id || "") === root.selectedAudioSourceId) {
                return source;
            }
        }

        return null;
    }

    function applyAudioSourceCatalog(nextSources) {
        const normalized = root.normalizedAudioSources(nextSources);
        root.audioSources = normalized;

        let selected = null;
        if (root.selectedAudioSourceId.length > 0) {
            for (let index = 0; index < normalized.length; index += 1) {
                const source = normalized[index];
                if (String(source.id || "") === root.selectedAudioSourceId) {
                    selected = source;
                    break;
                }
            }
        }

        if (!selected) {
            for (let index = 0; index < normalized.length; index += 1) {
                if (normalized[index].is_default) {
                    selected = normalized[index];
                    break;
                }
            }
        }

        if (!selected && normalized.length > 0) {
            selected = normalized[0];
        }

        root.selectedAudioSourceId = selected ? String(selected.id || "") : "";
        root.selectedAudioSourceName = selected ? String(selected.name || "") : "";
        root.selectedAudioSourceType = selected ? String(selected.type || "") : "";

        if (!selected) {
            root.audioMessage = root.audioCaptureAvailable
                ? "No audio sources were found. Refresh devices and check PipeWire."
                : "Audio capture is unavailable on this system.";
            return;
        }

        if (!root.recording && root.audioState !== "error") {
            root.audioMessage = "Ready to listen on " + root.selectedAudioSourceName + ".";
        }
    }

    function refreshAudioSources() {
        if (audioSourcesProcess.running) {
            return;
        }

        root.ensureBackendRunning();
        audioSourcesProcess.running = true;
    }

    function setSelectedAudioSource(sourceId) {
        const nextId = String(sourceId || "").trim();
        if (nextId.length === 0 || nextId === root.selectedAudioSourceId) {
            return;
        }

        if (root.recording) {
            root.feedback("info", "Stop live session first", "Stop the current audio session before switching sources.");
            return;
        }

        root.selectedAudioSourceId = nextId;
        const selected = root.selectedAudioSource();
        root.selectedAudioSourceName = selected ? String(selected.name || "") : "";
        root.selectedAudioSourceType = selected ? String(selected.type || "") : "";
        root.audioMessage = selected
            ? ("Ready to listen on " + root.selectedAudioSourceName + ".")
            : root.audioMessage;
    }

    function refreshAudioSession() {
        if (audioSessionProcess.running) {
            return;
        }

        root.ensureBackendRunning();
        audioSessionProcess.running = true;
    }

    function applyAudioSessionPayload(payload) {
        const sessionStatus = String(payload.status || "idle");
        root.audioSessionId = String(payload.session_id || "");
        root.recordedAudioPath = String(payload.capture_path || "");
        root.recording = sessionStatus === "starting" || sessionStatus === "listening" || sessionStatus === "speech_detected" || sessionStatus === "transcribing" || sessionStatus === "translating";
        root.audioState = sessionStatus;

        const sourceId = String(payload.selected_source_id || payload.source_id || "");
        if (sourceId.length > 0) {
            root.selectedAudioSourceId = sourceId;
        }

        const sourceName = String(payload.source_name || "");
        if (sourceName.length > 0) {
            root.selectedAudioSourceName = sourceName;
        }

        const sourceType = String(payload.selected_source_type || payload.source_type || "");
        if (sourceType.length > 0) {
            root.selectedAudioSourceType = sourceType;
        }

        root.transcriptSource = String(payload.current_partial_transcript || "");
        root.transcriptTarget = String(payload.current_partial_translation || "");
        root.audioMessage = String(payload.message || root.audioMessage || "");

        const lastError = String(payload.last_error || "").trim();
        if (lastError.length > 0 && sessionStatus === "error") {
            root.audioMessage = lastError;
        }
    }

    function runtimeDir() {
        const candidate = Quickshell.env("XDG_RUNTIME_DIR");
        return candidate && candidate.length > 0 ? candidate : "/tmp";
    }

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'";
    }

    function preferredModelFrom(list) {
        if (!list || list.length === 0) {
            return "";
        }

        if (root.activeModel.length > 0 && list.indexOf(root.activeModel) >= 0) {
            return root.activeModel;
        }

        if (root.preferredDefaultModel.length > 0 && list.indexOf(root.preferredDefaultModel) >= 0) {
            return root.preferredDefaultModel;
        }

        return list[0];
    }

    function applyModelCatalog(nextModels, sourceLabel) {
        const previousState = root.modelState;
        const unique = [];
        const seen = {};

        for (let index = 0; index < nextModels.length; index += 1) {
            const modelName = String(nextModels[index] || "").trim();
            if (modelName.length === 0 || seen[modelName]) {
                continue;
            }

            seen[modelName] = true;
            unique.push(modelName);
        }

        root.models = unique;
        root.ollamaAvailable = unique.length > 0;

        if (unique.length === 0) {
            root.activeModel = "";
            root.modelState = "offline";
            root.modelMessage = "No local models were found.";
            root.modelError = "Install a model with 'ollama pull' to start translating.";
            return;
        }

        const resolvedModel = root.preferredModelFrom(unique);
        const changedModel = resolvedModel !== root.activeModel;

        root.activeModel = resolvedModel;
        root.modelState = sourceLabel === "backend-warming" ? "warming" : "ready";
        root.modelMessage = sourceLabel === "api"
            ? (resolvedModel + " is ready.")
            : (sourceLabel === "backend-warming"
                ? (resolvedModel + " is warming.")
                : (resolvedModel + " is available."));
        root.modelError = "";
        root.backendAvailable = true;

        if (changedModel || previousState === "loading" || previousState === "offline" || previousState === "error") {
            root.fetchCurrentModel();
        }
    }

    function parseTagsOutput(rawText) {
        try {
            const payload = JSON.parse(rawText);
            if (!payload || !payload.models || payload.models.length === 0) {
                return [];
            }

            return payload.models.map(model => model.name || "").filter(modelName => modelName.length > 0);
        } catch (error) {
            return [];
        }
    }

    function parseOllamaList(rawText) {
        const output = String(rawText || "").trim();
        if (output.length === 0) {
            return [];
        }

        const lines = output.split("\n");
        const models = [];

        for (let index = 1; index < lines.length; index += 1) {
            const line = lines[index].trim();
            if (line.length === 0) {
                continue;
            }

            const firstColumn = line.split(/\s+/)[0] || "";
            if (firstColumn.length > 0) {
                models.push(firstColumn);
            }
        }

        return models;
    }

    function translationPrompt(sourceText, sourceLanguage, targetLanguage) {
        const directive = sourceLanguage === "Auto"
            ? ("Detect the source language and translate it into " + targetLanguage + ".")
            : ("Translate the following text from " + sourceLanguage + " into " + targetLanguage + ".");

        return [
            "You are a translation engine.",
            directive,
            "Preserve the meaning, line breaks, and formatting.",
            "Return only the translated text.",
            "",
            sourceText
        ].join("\n");
    }

    function discoverCapabilities() {
        if (capabilitiesProcess.running) {
            return;
        }

        capabilitiesProcess.running = true;
    }

    function refreshModelCatalog() {
        if (modelsProcess.running) {
            return;
        }

        root.modelState = "loading";
        root.modelMessage = root.backendAvailable ? "Refreshing local models..." : "Starting translation backend...";
        root.modelError = "";
        root.ensureBackendRunning();
        modelsProcess.running = true;
    }

    function selectModel(modelName) {
        const nextModel = String(modelName || "").trim();
        if (nextModel.length === 0 || nextModel === root.activeModel) {
            return;
        }

        if (root.translating) {
            root.feedback("info", "Translation in progress", "Wait for the current request to finish before switching models.");
            return;
        }

        root.activeModel = nextModel;
        root.pendingModelSelection = nextModel;
        if (selectModelProcess.running) {
            selectModelProcess.running = false;
        }
        selectModelProcess.running = true;
    }

    function fetchCurrentModel() {
        if (currentModelProcess.running) {
            return;
        }

        currentModelProcess.running = true;
    }

    function translateText(sourceText, sourceLanguage, targetLanguage) {
        const text = String(sourceText || "");
        if (text.trim().length === 0) {
            root.feedback("warning", "Nothing to translate", "Type or paste some text first.");
            return;
        }

        if (root.activeModel.length === 0) {
            root.feedback("warning", "No model selected", "Refresh Ollama and pick an installed model first.");
            root.refreshModelCatalog();
            return;
        }

        if (!root.backendAvailable) {
            root.feedback("warning", "Backend unavailable", "The translation backend is still starting. Try again in a moment.");
            root.ensureBackendRunning();
            return;
        }

        if (translationProcess.running) {
            translationProcess.running = false;
        }

        root.pendingSourceText = text;
        root.pendingSourceLanguage = sourceLanguage;
        root.pendingTargetLanguage = targetLanguage;
        root.translationError = "";
        root.translating = true;
        root.translationPayload = JSON.stringify({
            text: text,
            source_lang: sourceLanguage,
            target_lang: targetLanguage
        });
        translationProcess.running = true;
    }

    function ensureBackendRunning() {
        if (backendProcess.running) {
            if (!healthProcess.running) {
                healthProcess.running = true;
            }
            if (!modelsProcess.running && root.models.length === 0) {
                modelsProcess.running = true;
            }
            return;
        }

        backendProcess.running = true;
        healthPollTimer.restart();
    }

    function copyText(text) {
        if (!root.clipboardAvailable) {
            root.feedback("warning", "Clipboard unavailable", "wl-copy and wl-paste are required for copy actions.");
            return;
        }

        root.clipboardPayload = String(text || "");
        if (copyProcess.running) {
            copyProcess.running = false;
        }
        copyProcess.running = true;
    }

    function requestClipboardText() {
        if (!root.clipboardAvailable) {
            root.feedback("warning", "Clipboard unavailable", "wl-paste was not found on this system.");
            return;
        }

        if (pasteProcess.running) {
            return;
        }

        pasteProcess.running = true;
    }

    function pickImage() {
        if (!root.filePickerAvailable) {
            root.feedback("warning", "Image picker unavailable", "Install zenity to browse for an image file.");
            return;
        }

        if (pickImageProcess.running) {
            return;
        }

        pickImageProcess.running = true;
    }

    function captureScreenshot() {
        if (!root.screenshotAvailable) {
            root.feedback("warning", "Screenshot tools unavailable", "grim and slurp are required to capture a region.");
            return;
        }

        if (screenshotProcess.running) {
            return;
        }

        screenshotProcess.running = true;
    }

    function clearSelectedImage() {
        root.selectedImagePath = "";
        root.extractedText = "";
        root.ocrState = "idle";
        root.ocrMessage = "Upload or capture an image to continue.";
    }

    function languageToOcrCode(languageLabel) {
        switch (languageLabel) {
        case "English": return "eng";
        case "Spanish": return "spa";
        case "French": return "fra";
        case "German": return "deu";
        case "Portuguese": return "por";
        case "Portuguese (Brazil)": return "por";
        case "Italian": return "ita";
        case "Japanese": return "jpn";
        case "Korean": return "kor";
        case "Russian": return "rus";
        case "Chinese": return "chi_sim";
        default: return "";
        }
    }

    function runOcr(languageLabel) {
        if (!root.ocrAvailable) {
            root.feedback("warning", "OCR unavailable", "Install tesseract to extract text from images.");
            return;
        }

        if (root.selectedImagePath.length === 0) {
            root.feedback("warning", "No image selected", "Choose an image before running OCR.");
            return;
        }

        if (ocrProcess.running) {
            return;
        }

        root.ocrLanguageCode = root.languageToOcrCode(languageLabel);
        root.ocrState = "running";
        root.ocrMessage = "Extracting text from the current image...";
        ocrProcess.running = true;
    }

    function startRecording() {
        if (!root.audioCaptureAvailable) {
            root.feedback("warning", "Audio capture unavailable", "Install pw-record to enable local capture.");
            return;
        }

        if (root.selectedAudioSourceId.length === 0) {
            root.feedback("warning", "No audio source selected", "Choose a microphone or playback monitor first.");
            return;
        }

        if (audioStartProcess.running) {
            return;
        }

        root.audioState = "starting";
        root.audioMessage = "Starting live capture...";
        root.audioStartPayload = JSON.stringify({
            source_id: root.selectedAudioSourceId,
            source_lang: root.lastSourceLanguage && root.lastSourceLanguage.length > 0 ? root.lastSourceLanguage : "auto",
            target_lang: root.lastTargetLanguage && root.lastTargetLanguage.length > 0 ? root.lastTargetLanguage : "Portuguese (Brazil)"
        });
        audioStartProcess.running = true;
    }

    function stopRecording() {
        if (!root.recording || root.audioSessionId.length === 0) {
            return;
        }

        if (audioStopProcess.running) {
            return;
        }

        root.audioStopPayload = JSON.stringify({session_id: root.audioSessionId});
        audioStopProcess.running = true;
    }

    function toggleRecording() {
        if (root.recording) {
            root.stopRecording();
        } else {
            root.startRecording();
        }
    }

    function speak(text, slowMode) {
        const message = String(text || "").trim();
        if (message.length === 0) {
            root.feedback("warning", "Nothing to speak", "Translate something first, then use playback.");
            return;
        }

        if (!root.speechAvailable) {
            root.feedback("warning", "Speech output unavailable", "Install spd-say or espeak to enable playback.");
            return;
        }

        speechProcess.speakText = message;
        speechProcess.slowMode = slowMode;
        if (speechProcess.running) {
            speechProcess.running = false;
        }
        speechProcess.running = true;
    }

    onPanelVisibleChanged: {
        if (panelVisible) {
            root.ensureBackendRunning();
            root.discoverCapabilities();
            root.refreshModelCatalog();
            root.refreshAudioSources();
            root.refreshAudioSession();
        } else if (root.recording) {
            root.stopRecording();
        }
    }

    Component.onCompleted: {
        root.ensureBackendRunning();
        root.discoverCapabilities();
        root.refreshModelCatalog();
        root.refreshAudioSources();
        root.refreshAudioSession();
    }

    Timer {
        interval: 30000
        repeat: true
        running: root.panelVisible
        onTriggered: {
            root.ensureBackendRunning();
            root.discoverCapabilities();
            root.refreshModelCatalog();
            root.refreshAudioSources();
            root.refreshAudioSession();
        }
    }

    Timer {
        interval: 1500
        repeat: true
        running: root.panelVisible && (root.recording || root.audioSessionId.length > 0)
        onTriggered: root.refreshAudioSession()
    }

    Timer {
        id: healthPollTimer
        interval: 1200
        repeat: true
        running: false
        onTriggered: {
            if (!healthProcess.running) {
                healthProcess.running = true;
            }

            if (root.backendAvailable) {
                stop();
            }
        }
    }

    Process {
        id: backendProcess
        command: ["python3", root.backendScriptPath]
        stderr: StdioCollector {
            id: backendErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                if (!healthProcess.running) {
                    healthProcess.running = true;
                }
                root.modelMessage = "Reconnecting to translation backend...";
                root.modelError = String(backendErrorCollector.text || "").trim();
            }
        }
    }

    Process {
        id: healthProcess
        command: ["curl", "-s", root.backendUrl + "/health"]
        stdout: StdioCollector {
            id: healthCollector
        }
        stderr: StdioCollector {
            id: healthErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.backendAvailable = false;
                root.modelState = "loading";
                root.modelMessage = "Waiting for translation backend...";
                root.modelError = String(healthErrorCollector.text || "").trim();
                return;
            }

            try {
                const payload = JSON.parse(String(healthCollector.text || "{}"));
                root.backendAvailable = payload.backend === "ok";
                if (root.backendAvailable && payload.ollama === "ok" && root.modelState === "loading") {
                    root.modelState = "ready";
                    root.modelMessage = root.activeModel.length > 0 ? (root.activeModel + " is ready.") : "Translation backend ready.";
                    root.modelError = "";
                } else if (payload.ollama !== "ok") {
                    root.modelState = "offline";
                    root.modelMessage = "Ollama is not running.";
                }
            } catch (error) {
                root.backendAvailable = false;
            }
        }
    }

    Process {
        id: audioSourcesProcess
        command: ["curl", "-s", root.backendUrl + "/audio/sources"]
        stdout: StdioCollector {
            id: audioSourcesCollector
        }
        stderr: StdioCollector {
            id: audioSourcesErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.audioState = "error";
                root.audioMessage = String(audioSourcesErrorCollector.text || "").trim().length > 0
                    ? String(audioSourcesErrorCollector.text || "").trim()
                    : "Unable to load audio sources.";
                return;
            }

            try {
                const payload = JSON.parse(String(audioSourcesCollector.text || "{}"));
                root.applyAudioSourceCatalog(Array.isArray(payload.sources) ? payload.sources : []);
            } catch (error) {
                root.audioState = "error";
                root.audioMessage = "The backend returned malformed audio source data.";
            }
        }
    }

    Process {
        id: audioSessionProcess
        command: ["curl", "-s", root.backendUrl + "/audio/live/session"]
        stdout: StdioCollector {
            id: audioSessionCollector
        }
        stderr: StdioCollector {
            id: audioSessionErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.audioState = "error";
                root.audioMessage = String(audioSessionErrorCollector.text || "").trim().length > 0
                    ? String(audioSessionErrorCollector.text || "").trim()
                    : "Unable to read live session state.";
                return;
            }

            try {
                const payload = JSON.parse(String(audioSessionCollector.text || "{}"));
                root.applyAudioSessionPayload(payload);
            } catch (error) {
                root.audioState = "error";
                root.audioMessage = "The backend returned malformed live session data.";
            }
        }
    }

    Process {
        id: audioStartProcess
        command: [
            "curl",
            "-s",
            "-X",
            "POST",
            "-H",
            "Content-Type: application/json",
            "-d",
            root.audioStartPayload,
            root.backendUrl + "/audio/live/start"
        ]
        stdout: StdioCollector {
            id: audioStartCollector
        }
        stderr: StdioCollector {
            id: audioStartErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.recording = false;
                root.audioState = "error";
                root.audioMessage = String(audioStartErrorCollector.text || "").trim().length > 0
                    ? String(audioStartErrorCollector.text || "").trim()
                    : "Unable to start live audio translation.";
                root.feedback("error", "Live audio start failed", root.audioMessage);
                return;
            }

            try {
                const payload = JSON.parse(String(audioStartCollector.text || "{}"));
                if (payload.status === "error") {
                    root.recording = false;
                    root.audioState = "error";
                    root.audioMessage = String(payload.message || "Unable to start live audio translation.");
                    root.feedback("error", "Live audio start failed", root.audioMessage);
                    return;
                }

                root.applyAudioSessionPayload(payload);
            } catch (error) {
                root.recording = false;
                root.audioState = "error";
                root.audioMessage = "The backend returned malformed live start data.";
                root.feedback("error", "Live audio start failed", root.audioMessage);
            }
        }
    }

    Process {
        id: audioStopProcess
        command: [
            "curl",
            "-s",
            "-X",
            "POST",
            "-H",
            "Content-Type: application/json",
            "-d",
            root.audioStopPayload,
            root.backendUrl + "/audio/live/stop"
        ]
        stdout: StdioCollector {
            id: audioStopCollector
        }
        stderr: StdioCollector {
            id: audioStopErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.audioState = "error";
                root.audioMessage = String(audioStopErrorCollector.text || "").trim().length > 0
                    ? String(audioStopErrorCollector.text || "").trim()
                    : "Unable to stop live audio translation.";
                root.feedback("error", "Live audio stop failed", root.audioMessage);
                return;
            }

            try {
                const payload = JSON.parse(String(audioStopCollector.text || "{}"));
                if (payload.status === "error") {
                    root.audioState = "error";
                    root.audioMessage = String(payload.message || "Unable to stop live audio translation.");
                    root.feedback("error", "Live audio stop failed", root.audioMessage);
                    return;
                }

                root.applyAudioSessionPayload(payload);
            } catch (error) {
                root.audioState = "error";
                root.audioMessage = "The backend returned malformed live stop data.";
                root.feedback("error", "Live audio stop failed", root.audioMessage);
            }
        }
    }

    Process {
        id: capabilitiesProcess
        command: [
            "bash",
            "-lc",
            "for tool in zenity wl-paste wl-copy grim slurp tesseract pw-record spd-say espeak; do if command -v \"$tool\" >/dev/null 2>&1; then printf \"%s=1\\n\" \"$tool\"; else printf \"%s=0\\n\" \"$tool\"; fi; done"
        ]
        stdout: StdioCollector {
            id: capabilitiesCollector
        }
        onExited: code => {
            if (code !== 0) {
                return;
            }

            const flags = {};
            const lines = String(capabilitiesCollector.text || "").trim().split("\n");
            for (let index = 0; index < lines.length; index += 1) {
                const line = lines[index].trim();
                if (line.length === 0 || line.indexOf("=") < 0) {
                    continue;
                }

                const parts = line.split("=");
                flags[parts[0]] = parts[1] === "1";
            }

            root.zenityAvailable = !!flags["zenity"];
            root.wlPasteAvailable = !!flags["wl-paste"];
            root.wlCopyAvailable = !!flags["wl-copy"];
            root.grimAvailable = !!flags["grim"];
            root.slurpAvailable = !!flags["slurp"];
            root.tesseractAvailable = !!flags["tesseract"];
            root.pwRecordAvailable = !!flags["pw-record"];
            root.spdSayAvailable = !!flags["spd-say"];
            root.espeakAvailable = !!flags["espeak"];
            root.capabilitiesLoaded = true;

            if (!root.tesseractAvailable && root.selectedImagePath.length > 0 && root.extractedText.length === 0) {
                root.ocrMessage = "Install tesseract to extract text from the selected image.";
            }
        }
    }

    Process {
        id: modelsProcess
        command: ["curl", "-s", root.backendUrl + "/models"]
        stdout: StdioCollector {
            id: modelsCollector
        }
        stderr: StdioCollector {
            id: modelsErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.backendAvailable = false;
                root.modelState = "offline";
                root.modelMessage = "Translation backend unavailable.";
                root.modelError = String(modelsErrorCollector.text || "").trim().length > 0
                    ? String(modelsErrorCollector.text || "").trim()
                    : "The local translation backend did not respond.";
                return;
            }

            try {
                const payload = JSON.parse(String(modelsCollector.text || "{}"));
                const modelNames = Array.isArray(payload.models) ? payload.models : [];
                root.applyModelCatalog(modelNames, "backend");
                root.fetchCurrentModel();
            } catch (error) {
                root.modelState = "error";
                root.modelMessage = "Invalid model list response.";
                root.modelError = "The backend returned malformed model data.";
            }
        }
    }

    Process {
        id: currentModelProcess
        command: ["curl", "-s", root.backendUrl + "/models/current"]
        stdout: StdioCollector {
            id: currentModelCollector
        }
        stderr: StdioCollector {
            id: currentModelErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.modelState = "offline";
                root.modelMessage = "Current model status is unavailable.";
                root.modelError = String(currentModelErrorCollector.text || "").trim();
                return;
            }

            try {
                const payload = JSON.parse(String(currentModelCollector.text || "{}"));
                root.activeModel = String(payload.model || root.activeModel || "");
                root.modelState = String(payload.status || "ready");
                root.modelMessage = root.modelState === "warming"
                    ? (root.activeModel + " is warming.")
                    : (root.activeModel.length > 0 ? (root.activeModel + " is ready.") : "No active model selected.");
                root.modelError = "";
                root.backendAvailable = true;
            } catch (error) {
                root.modelState = "error";
                root.modelMessage = "Invalid current model response.";
                root.modelError = "The backend returned malformed model status data.";
            }
        }
    }

    Process {
        id: selectModelProcess
        command: [
            "curl",
            "-s",
            "-X",
            "POST",
            "-H",
            "Content-Type: application/json",
            "-d",
            JSON.stringify({model: root.pendingModelSelection}),
            root.backendUrl + "/models/select"
        ]
        stdout: StdioCollector {
            id: selectModelCollector
        }
        stderr: StdioCollector {
            id: selectModelErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.modelState = "error";
                root.modelMessage = "Could not switch the active model.";
                root.modelError = String(selectModelErrorCollector.text || "").trim().length > 0
                    ? String(selectModelErrorCollector.text || "").trim()
                    : "The backend did not accept the model selection request.";
                return;
            }

            try {
                const payload = JSON.parse(String(selectModelCollector.text || "{}"));
                root.activeModel = String(payload.model || root.pendingModelSelection || root.activeModel);
                root.modelState = String(payload.status || "warming");
                root.modelMessage = root.modelState === "warming"
                    ? (root.activeModel + " is warming.")
                    : (root.activeModel + " is ready.");
                root.modelError = "";
                root.backendAvailable = true;
                root.fetchCurrentModel();
            } catch (error) {
                root.modelState = "error";
                root.modelMessage = "Invalid model selection response.";
                root.modelError = "The backend returned malformed model selection data.";
            }
        }
    }

    Process {
        id: translationProcess
        command: [
            "curl",
            "-s",
            "-X",
            "POST",
            "-H",
            "Content-Type: application/json",
            "-d",
            root.translationPayload,
            root.backendUrl + "/translate/text"
        ]
        stdout: StdioCollector {
            id: translationCollector
        }
        stderr: StdioCollector {
            id: translationErrorCollector
        }
        onExited: code => {
            root.translating = false;

            if (code !== 0) {
                root.translationError = String(translationErrorCollector.text || "").trim().length > 0
                    ? String(translationErrorCollector.text || "").trim()
                    : "The translation request failed before Ollama returned a response.";
                root.feedback("error", "Translation failed", root.translationError);
                root.modelState = "error";
                root.modelMessage = "Translation request failed.";
                root.modelError = root.translationError;
                return;
            }

            try {
                const payload = JSON.parse(String(translationCollector.text || "{}"));
                if (payload.status === "error") {
                    root.translationError = String(payload.message || "Translation failed.");
                    root.feedback("error", "Translation failed", root.translationError);
                    root.modelState = "error";
                    root.modelMessage = "Translation request failed.";
                    root.modelError = root.translationError;
                    return;
                }

                const responseText = String(payload.translated_text || "").trim();
                if (responseText.length === 0) {
                    throw new Error("Empty translation response");
                }

                root.translatedText = responseText;
                root.translationError = "";
                root.lastTranslatedAt = Date.now();
                root.lastSourceText = root.pendingSourceText;
                root.lastSourceLanguage = String(payload.detected_source_lang || root.pendingSourceLanguage);
                root.lastTargetLanguage = String(payload.target_lang || root.pendingTargetLanguage);
                root.lastTranslationModel = String(payload.model || root.activeModel);
                root.transcriptTarget = responseText;
                root.modelState = "ready";
                root.modelMessage = root.lastTranslationModel + " translated the latest request.";
                root.modelError = "";
                root.translationCompleted(
                    root.pendingSourceText,
                    responseText,
                    root.lastSourceLanguage,
                    root.lastTargetLanguage
                );
            } catch (error) {
                root.translationError = "Ollama returned an unexpected payload.";
                root.feedback("error", "Translation failed", root.translationError);
            }
        }
    }

    Process {
        id: copyProcess
        command: ["bash", "-lc", "printf %s " + root.shellQuote(root.clipboardPayload) + " | wl-copy"]
        onExited: code => {
            if (code === 0) {
                root.feedback("success", "Copied", "The current text was copied to the clipboard.");
            } else {
                root.feedback("error", "Copy failed", "The clipboard command did not complete successfully.");
            }
        }
    }

    Process {
        id: pasteProcess
        command: ["wl-paste", "--no-newline"]
        stdout: StdioCollector {
            id: pasteCollector
        }
        stderr: StdioCollector {
            id: pasteErrorCollector
        }
        onExited: code => {
            if (code === 0) {
                root.clipboardTextReady(String(pasteCollector.text || ""));
                return;
            }

            const errorMessage = String(pasteErrorCollector.text || "").trim();
            root.feedback("error", "Paste failed", errorMessage.length > 0 ? errorMessage : "The clipboard did not contain readable text.");
        }
    }

    Process {
        id: pickImageProcess
        command: [
            "zenity",
            "--file-selection",
            "--title=Select image to translate",
            "--file-filter=Image files | *.png *.jpg *.jpeg *.webp *.bmp *.heic"
        ]
        stdout: StdioCollector {
            id: pickImageCollector
        }
        onExited: code => {
            if (code !== 0) {
                return;
            }

            const path = String(pickImageCollector.text || "").trim();
            if (path.length === 0) {
                return;
            }

            root.selectedImagePath = path;
            root.extractedText = "";
            root.ocrState = "idle";
            root.ocrMessage = root.ocrAvailable
                ? "Run OCR to extract text from the selected image."
                : "Install tesseract to extract text from the selected image.";
        }
    }

    Process {
        id: screenshotProcess
        command: [
            "bash",
            "-lc",
            "file=\"" + root.runtimeDir() + "/translate-shot-$(date +%s).png\"; selection=$(slurp) || exit 1; grim -g \"$selection\" \"$file\" && printf %s \"$file\""
        ]
        stdout: StdioCollector {
            id: screenshotCollector
        }
        stderr: StdioCollector {
            id: screenshotErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                const errorMessage = String(screenshotErrorCollector.text || "").trim();
                if (errorMessage.length > 0) {
                    root.feedback("warning", "Screenshot cancelled", errorMessage);
                }
                return;
            }

            const path = String(screenshotCollector.text || "").trim();
            if (path.length === 0) {
                return;
            }

            root.selectedImagePath = path;
            root.extractedText = "";
            root.ocrState = "idle";
            root.ocrMessage = root.ocrAvailable
                ? "Screenshot captured. Run OCR when you are ready."
                : "Screenshot captured. Install tesseract to extract text from it.";
        }
    }

    Process {
        id: ocrProcess
        command: {
            const nextCommand = ["tesseract", root.selectedImagePath, "stdout"];
            if (root.ocrLanguageCode.length > 0) {
                nextCommand.push("-l", root.ocrLanguageCode);
            }
            return nextCommand;
        }
        stdout: StdioCollector {
            id: ocrCollector
        }
        stderr: StdioCollector {
            id: ocrErrorCollector
        }
        onExited: code => {
            if (code !== 0) {
                root.ocrState = "error";
                root.ocrMessage = String(ocrErrorCollector.text || "").trim().length > 0
                    ? String(ocrErrorCollector.text || "").trim()
                    : "The OCR command did not return text.";
                root.feedback("error", "OCR failed", root.ocrMessage);
                return;
            }

            const text = String(ocrCollector.text || "").trim();
            root.extractedText = text;
            root.ocrState = text.length > 0 ? "ready" : "error";
            root.ocrMessage = text.length > 0
                ? "Review the extracted text before translating it."
                : "No text was detected in the selected image.";

            if (text.length > 0) {
                root.ocrCompleted(text);
            }
        }
    }

    Process {
        id: speechProcess
        property string speakText: ""
        property bool slowMode: false
        command: root.spdSayAvailable
            ? ["spd-say", "-r", slowMode ? "-35" : "0", speakText]
            : ["espeak", "-s", slowMode ? "140" : "185", speakText]
        onExited: code => {
            if (code !== 0) {
                root.feedback("warning", "Speech output failed", "The playback command did not complete successfully.");
            }
        }
    }
}
