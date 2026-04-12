//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./services"
import "./shared/designsystem" as Design

ShellRoot {
    id: shellRoot

    property bool panelOpen: false
    property int activeTab: 0
    property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

    property string sourceLanguage: "English"
    property string targetLanguage: "Portuguese (Brazil)"
    property string sourceText: ""
    property string feedbackKind: "info"
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool sourceMenuOpen: false
    property bool targetMenuOpen: false
    property bool modelMenuOpen: false
    property bool audioSourceMenuOpen: false
    property int waveformTick: 0
    property string imageSourceLanguage: "English"
    property string imageTargetLanguage: "Spanish"
    property string audioSourceLanguage: "Auto"
    property string audioTargetLanguage: "Portuguese (Brazil)"

    readonly property var languageOptions: [
        "Auto",
        "English",
        "Spanish",
        "French",
        "German",
        "Portuguese",
        "Portuguese (Brazil)",
        "Italian",
        "Japanese",
        "Korean",
        "Russian",
        "Chinese"
    ]

    readonly property int maxCharacters: 5000
    readonly property color panelTone: Design.ThemePalette.mix(Design.Tokens.color.bg.surface, Design.Tokens.color.bg.canvas, 0.18)
    readonly property color cardTone: Design.ThemePalette.mix(Design.Tokens.color.bg.elevated, Design.Tokens.color.surfaceVariant, Design.ThemeSettings.isDark ? 0.08 : 0.03)
    readonly property color deepTone: Design.ThemePalette.mix(Design.Tokens.color.bg.canvas, Design.Tokens.color.bg.surface, 0.15)
    readonly property color accentTone: Design.ThemePalette.mix(Design.Tokens.color.accent.primary, Design.ThemePalette.white, Design.ThemeSettings.isDark ? 0.18 : 0.04)
    readonly property color accentSolidTone: Design.Tokens.color.accent.primary
    readonly property color accentForegroundTone: Design.ThemeSettings.isDark ? Design.ThemePalette.black : Design.ThemePalette.white
    readonly property color textPrimaryTone: Design.Tokens.color.text.primary
    readonly property color textSecondaryTone: Design.Tokens.color.text.secondary
    readonly property color textMutedTone: Design.Tokens.color.text.muted
    readonly property color borderTone: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, Design.ThemeSettings.isDark ? 0.78 : 0.58)
    readonly property color subtleBorderTone: Design.ThemePalette.withAlpha(Design.ThemePalette.white, Design.ThemeSettings.isDark ? 0.08 : 0.06)
    readonly property color successTone: Design.ThemePalette.mix(Design.Tokens.color.success, "#93f073", 0.35)
    readonly property color errorTone: Design.Tokens.color.error
    readonly property color warningTone: Design.Tokens.color.warning
    readonly property color glowTone: Design.ThemePalette.withAlpha(accentSolidTone, Design.ThemeSettings.isDark ? 0.28 : 0.18)
    readonly property string uiFontFamily: Design.Tokens.font.family.body
    readonly property string monoFontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: Design.Tokens.font.family.icon

    function resolveScreen() {
        for (let index = 0; index < Quickshell.screens.values.length; index += 1) {
            if (Quickshell.screens.values[index].name === shellRoot.focusedScreenName) {
                return Quickshell.screens.values[index];
            }
        }

        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    function showFeedback(kind, title, message) {
        feedbackKind = kind;
        feedbackTitle = title;
        feedbackMessage = message;
        feedbackTimer.restart();
    }

    function closeMenus() {
        sourceMenuOpen = false;
        targetMenuOpen = false;
        modelMenuOpen = false;
        audioSourceMenuOpen = false;
    }

    function clampSourceText(nextText) {
        if (nextText.length <= maxCharacters) {
            return nextText;
        }

        return nextText.slice(0, maxCharacters);
    }

    function setSourceText(nextText) {
        sourceText = clampSourceText(String(nextText || ""));
    }

    onSourceTextChanged: {
        if (sourceInput.text !== sourceText) {
            sourceInput.text = sourceText;
        }
    }

    Connections {
        target: translateService

        function onExtractedTextChanged() {
            if (ocrOutput.text !== translateService.extractedText) {
                ocrOutput.text = translateService.extractedText;
            }
        }

        function onRecordingChanged() {
            if (translateService.recording) {
                waveformTick = 0;
            }
        }
    }

    function swapLanguages() {
        if (sourceLanguage === "Auto") {
            return;
        }

        const previousSource = sourceLanguage;
        sourceLanguage = targetLanguage;
        targetLanguage = previousSource;
    }

    function typingStatusText() {
        if (translateService.translating) {
            return "Translating";
        }

        if (sourceText.trim().length > 0) {
            return "Typing";
        }

        return "Idle";
    }

    function targetMenuX() {
        return Math.max(0, contentFrame.width - targetLanguageMenu.width - 24);
    }

    function audioSourceMenuX() {
        return 24;
    }

    function audioSourceSummary() {
        if (translateService.selectedAudioSourceName.length > 0) {
            return translateService.selectedAudioSourceName;
        }

        return "Choose source";
    }

    function audioSourceTypeLabel() {
        if (translateService.selectedAudioSourceType === "playback_monitor") {
            return "Playback";
        }

        if (translateService.selectedAudioSourceType === "input") {
            return "Microphone";
        }

        return "Source";
    }

    function translationStatusText() {
        if (translateService.translating) {
            return "Working now";
        }

        if (translateService.lastTranslatedAt > 0) {
            return relativeTime(translateService.lastTranslatedAt);
        }

        return "Waiting for input";
    }

    function relativeTime(timestamp) {
        if (!timestamp) {
            return "Updated just now";
        }

        const elapsedSeconds = Math.max(0, Math.floor((Date.now() - timestamp) / 1000));
        if (elapsedSeconds < 10) return "Updated just now";
        if (elapsedSeconds < 60) return "Updated " + elapsedSeconds + "s ago";

        const elapsedMinutes = Math.floor(elapsedSeconds / 60);
        if (elapsedMinutes < 60) return "Updated " + elapsedMinutes + "m ago";

        const elapsedHours = Math.floor(elapsedMinutes / 60);
        return "Updated " + elapsedHours + "h ago";
    }

    function iconGlyph(name) {
        switch (name) {
        case "history": return "󰋚";
        case "bookmark": return "󰃀";
        case "swap": return "󰓣";
        case "paste": return "󰅌";
        case "mic": return "󰍬";
        case "close": return "󰅖";
        case "copy": return "󰆏";
        case "share": return "󰤲";
        case "volume": return "󰕾";
        case "bolt": return "󰚥";
        case "upload": return "󰈷";
        case "camera": return "󰄀";
        case "check": return "󰄬";
        case "dropdown": return "󰅂";
        case "translate": return "󰗊";
        case "play": return "󰐊";
        case "slow": return "󰒲";
        case "ocr": return "󱓷";
        default: return "•";
        }
    }

    IpcHandler {
        target: "translate"

        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }

        function open() {
            shellRoot.panelOpen = true;
        }

        function close() {
            shellRoot.panelOpen = false;
        }

        function showTab(tabName: string) {
            shellRoot.panelOpen = true;
            if (tabName === "image") shellRoot.activeTab = 1;
            else if (tabName === "audio") shellRoot.activeTab = 2;
            else shellRoot.activeTab = 0;
        }
    }

    Timer {
        id: feedbackTimer
        interval: 4200
        running: false
        repeat: false
        onTriggered: {
            feedbackTitle = "";
            feedbackMessage = "";
        }
    }

    Timer {
        interval: 140
        running: shellRoot.panelOpen && translateService.recording
        repeat: true
        onTriggered: shellRoot.waveformTick += 1
    }

    component GlyphText: Text {
        font.family: shellRoot.iconFontFamily
        font.pixelSize: 18
        font.weight: Font.Medium
        color: shellRoot.textPrimaryTone
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    component ActionCircle: Rectangle {
        id: actionCircle

        signal clicked()

        property string glyph: ""
        property bool active: false
        property bool enabledButton: true
        property color fillTone: active ? shellRoot.accentTone : shellRoot.deepTone
        property color glyphTone: active ? shellRoot.accentForegroundTone : shellRoot.textPrimaryTone

        width: 36
        height: 36
        radius: 18
        color: fillTone
        border.width: 1
        border.color: active ? Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.32) : shellRoot.subtleBorderTone
        opacity: enabledButton ? 1 : 0.4

        GlyphText {
            anchors.centerIn: parent
            text: actionCircle.glyph
            color: actionCircle.glyphTone
            font.pixelSize: 17
        }

        MouseArea {
            anchors.fill: parent
            enabled: actionCircle.enabledButton
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: actionCircle.clicked()
        }
    }

    component PillButton: Rectangle {
        id: pillButton

        signal clicked()

        property string text: ""
        property string glyph: ""
        property bool selected: false
        property bool outlined: false
        property bool enabledButton: true
        property color bgTone: selected
            ? shellRoot.accentSolidTone
            : (outlined ? "transparent" : shellRoot.cardTone)
        property color fgTone: selected
            ? shellRoot.accentForegroundTone
            : (outlined ? shellRoot.accentTone : shellRoot.textPrimaryTone)

        implicitHeight: 40
        radius: 20
        color: bgTone
        border.width: 1
        border.color: selected
            ? Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.35)
            : (outlined ? shellRoot.subtleBorderTone : shellRoot.borderTone)
        opacity: enabledButton ? 1 : 0.45

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            GlyphText {
                visible: pillButton.glyph.length > 0
                text: pillButton.glyph
                color: pillButton.fgTone
                font.pixelSize: 15
            }

            Text {
                text: pillButton.text
                color: pillButton.fgTone
                font.family: shellRoot.uiFontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: pillButton.enabledButton
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: pillButton.clicked()
        }
    }

    component StatusChip: Rectangle {
        id: statusChip

        property color dotColor: shellRoot.successTone
        property string label: ""

        implicitHeight: 28
        radius: 14
        color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.08)
        border.width: 1
        border.color: shellRoot.subtleBorderTone

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: statusChip.dotColor
            }

            Text {
                text: statusChip.label
                color: shellRoot.textPrimaryTone
                font.family: shellRoot.uiFontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    component LanguageMenu: Rectangle {
        id: menuRoot

        property var options: []
        property string selectedValue: ""
        property string title: ""
        signal valueSelected(string value)

        radius: 18
        color: shellRoot.deepTone
        border.width: 1
        border.color: shellRoot.borderTone
        visible: false
        implicitWidth: 170
        implicitHeight: menuColumn.implicitHeight + 18
        z: 20

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 9
            spacing: 4

            Text {
                text: menuRoot.title
                color: shellRoot.textMutedTone
                font.family: shellRoot.monoFontFamily
                font.pixelSize: 10
                font.weight: Font.DemiBold
                leftPadding: 8
                topPadding: 2
                bottomPadding: 4
            }

            Repeater {
                model: menuRoot.options

                delegate: Rectangle {
                    required property var modelData

                    width: menuRoot.width - 18
                    height: 32
                    radius: 12
                    color: modelData === menuRoot.selectedValue
                        ? Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.18)
                        : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: modelData === menuRoot.selectedValue ? shellRoot.accentTone : shellRoot.textPrimaryTone
                        font.family: shellRoot.uiFontFamily
                        font.pixelSize: 12
                        font.weight: modelData === menuRoot.selectedValue ? Font.DemiBold : Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menuRoot.valueSelected(modelData)
                    }
                }
            }
        }
    }

    component ModelMenu: Rectangle {
        id: modelMenuRoot

        property var models: []
        property string selectedValue: ""
        signal valueSelected(string modelName)

        radius: 18
        color: shellRoot.deepTone
        border.width: 1
        border.color: shellRoot.borderTone
        visible: false
        implicitWidth: 190
        implicitHeight: Math.min(modelColumn.implicitHeight + 18, 240)
        z: 20

        Flickable {
            anchors.fill: parent
            anchors.margins: 9
            contentWidth: width
            contentHeight: modelColumn.implicitHeight
            clip: true

            Column {
                id: modelColumn
                width: parent.width
                spacing: 4

                Text {
                    text: "AVAILABLE MODELS"
                    color: shellRoot.textMutedTone
                    font.family: shellRoot.monoFontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    leftPadding: 8
                    topPadding: 2
                    bottomPadding: 4
                }

                Repeater {
                    model: modelMenuRoot.models

                    delegate: Rectangle {
                        required property var modelData

                        width: modelColumn.width
                        height: 34
                        radius: 12
                        color: modelData === modelMenuRoot.selectedValue
                            ? Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.18)
                            : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            color: modelData === modelMenuRoot.selectedValue ? shellRoot.accentTone : shellRoot.textPrimaryTone
                            font.family: shellRoot.monoFontFamily
                            font.pixelSize: 12
                            font.weight: modelData === modelMenuRoot.selectedValue ? Font.DemiBold : Font.Medium
                            elide: Text.ElideRight
                            width: parent.width - 20
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelMenuRoot.valueSelected(modelData)
                        }
                    }
                }
            }
        }
    }

    TranslateService {
        id: translateService
        panelVisible: shellRoot.panelOpen

        onFeedback: (kind, title, message) => shellRoot.showFeedback(kind, title, message)
        onClipboardTextReady: text => shellRoot.setSourceText(shellRoot.sourceText.length > 0 ? (shellRoot.sourceText + "\n" + text) : text)
        onOcrCompleted: text => {
            if (ocrOutput.text !== text) {
                ocrOutput.text = text;
            }
            if (shellRoot.activeTab === 1) {
                shellRoot.setSourceText(text);
            }
        }
        onTranslationCompleted: (source, translated, sourceLabel, targetLabel) => {
            shellRoot.sourceLanguage = sourceLabel === "Auto" ? shellRoot.sourceLanguage : sourceLabel;
            shellRoot.targetLanguage = targetLabel;
            translateService.transcriptSource = source;
            translateService.transcriptTarget = translated;
        }
    }

    PanelWindow {
        id: window

        screen: shellRoot.resolveScreen()
        color: "transparent"
        visible: shellRoot.panelOpen || contentFrame.opacity > 0

        WlrLayershell.namespace: "quickshell:translate"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shellRoot.panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: shellRoot.panelOpen
            onClicked: {
                shellRoot.closeMenus();
                shellRoot.panelOpen = false;
            }
        }

        FocusScope {
            id: contentFrame
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 400
            opacity: shellRoot.panelOpen ? 1 : 0
            x: shellRoot.panelOpen ? 0 : 24
            focus: shellRoot.panelOpen

            Keys.onEscapePressed: event => {
                shellRoot.closeMenus();
                shellRoot.panelOpen = false;
                event.accepted = true;
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: parent.width
                color: shellRoot.panelTone
                border.width: 1
                border.color: shellRoot.borderTone
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    layer.enabled: true
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: 1
                    color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.12)
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 160
                    color: "transparent"

                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: -72
                        width: 230
                        height: 230
                        radius: 115
                        color: shellRoot.glowTone
                        opacity: 0.9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => {
                        shellRoot.closeMenus();
                        mouse.accepted = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 20
                    anchors.bottomMargin: 0
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: "Monolith Translate"
                                color: shellRoot.accentTone
                                font.family: shellRoot.uiFontFamily
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: translateService.modelState === "ready"
                                    ? ("Using " + translateService.activeModel)
                                    : translateService.modelMessage
                                color: shellRoot.textMutedTone
                                font.family: shellRoot.monoFontFamily
                                font.pixelSize: 10
                                font.weight: Font.Medium
                            }
                        }

                        ActionCircle {
                            glyph: shellRoot.iconGlyph("history")
                            onClicked: shellRoot.showFeedback("info", "History", "Translation history is not wired yet.")
                        }

                        ActionCircle {
                            glyph: shellRoot.iconGlyph("bookmark")
                            onClicked: shellRoot.showFeedback("info", "Bookmarks", "Saved phrase collections are planned for a later pass.")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: 24
                        color: shellRoot.deepTone
                        border.width: 1
                        border.color: shellRoot.subtleBorderTone

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            Repeater {
                                model: ["TEXT", "IMAGE", "AUDIO"]

                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 18
                                    color: shellRoot.activeTab === index
                                        ? Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.08)
                                        : "transparent"

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 18
                                        anchors.rightMargin: 18
                                        height: 2
                                        radius: 1
                                        color: shellRoot.activeTab === index ? shellRoot.accentSolidTone : "transparent"
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: shellRoot.activeTab === index ? shellRoot.accentTone : shellRoot.textSecondaryTone
                                        font.family: shellRoot.monoFontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            shellRoot.activeTab = index;
                                            shellRoot.closeMenus();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        id: contentFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: contentColumn.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: contentColumn
                            width: contentFlick.width
                            spacing: shellRoot.activeTab === 2 ? 20 : 24

                            Item {
                                width: parent.width
                                visible: shellRoot.activeTab === 0
                                height: visible ? textTabColumn.implicitHeight : 0

                                Column {
                                    id: textTabColumn
                                    width: parent.width
                                    spacing: 24

                                    Item {
                                        id: languageSelectorRow
                                        width: parent.width
                                        height: 44

                                        Rectangle {
                                            id: languagePill
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            height: 44
                                            radius: 22
                                            color: shellRoot.cardTone
                                            border.width: 1
                                            border.color: shellRoot.subtleBorderTone

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                spacing: 6

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    radius: 18
                                                    color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.14)

                                                    Text {
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 18
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: shellRoot.sourceLanguage
                                                        color: shellRoot.sourceLanguage === "Auto" ? shellRoot.textPrimaryTone : shellRoot.accentForegroundTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 13
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Rectangle {
                                                        visible: shellRoot.sourceLanguage !== "Auto"
                                                        anchors.fill: parent
                                                        radius: parent.radius
                                                        color: shellRoot.accentSolidTone
                                                        z: -1
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            shellRoot.sourceMenuOpen = !shellRoot.sourceMenuOpen;
                                                            shellRoot.targetMenuOpen = false;
                                                            shellRoot.modelMenuOpen = false;
                                                        }
                                                    }
                                                }

                                                ActionCircle {
                                                    width: 36
                                                    height: 36
                                                    glyph: shellRoot.iconGlyph("swap")
                                                    enabledButton: shellRoot.sourceLanguage !== "Auto"
                                                    onClicked: shellRoot.swapLanguages()
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    radius: 18
                                                    color: "transparent"

                                                    Text {
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 18
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: shellRoot.targetLanguage
                                                        color: shellRoot.accentTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 13
                                                        font.weight: Font.DemiBold
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            shellRoot.targetMenuOpen = !shellRoot.targetMenuOpen;
                                                            shellRoot.sourceMenuOpen = false;
                                                            shellRoot.modelMenuOpen = false;
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 272
                                        radius: 26
                                        color: shellRoot.cardTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 20
                                            spacing: 14

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: "Text"
                                                        color: shellRoot.textPrimaryTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 18
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Text {
                                                        text: shellRoot.sourceLanguage === "Auto"
                                                            ? "Detect language automatically"
                                                            : ("Detected as " + shellRoot.sourceLanguage)
                                                        color: shellRoot.textMutedTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 12
                                                    }
                                                }

                                                StatusChip {
                                                    label: shellRoot.typingStatusText()
                                                    dotColor: translateService.translating ? shellRoot.accentTone : shellRoot.successTone
                                                }
                                            }

                                            TextArea {
                                                id: sourceInput
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                text: ""
                                                wrapMode: TextEdit.Wrap
                                                selectByMouse: true
                                                color: shellRoot.textPrimaryTone
                                                placeholderText: "Type something to translate, paste from the clipboard, or bring in OCR text from the image tab."
                                                placeholderTextColor: shellRoot.textMutedTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 28
                                                font.weight: Font.Medium
                                                leftPadding: 0
                                                rightPadding: 0
                                                topPadding: 0
                                                bottomPadding: 0
                                                background: Item {}
                                                onTextChanged: {
                                                    const clamped = shellRoot.clampSourceText(text);
                                                    if (clamped !== text) {
                                                        text = clamped;
                                                        return;
                                                    }
                                                    shellRoot.sourceText = clamped;
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                Text {
                                                    text: shellRoot.sourceText.length + "/" + shellRoot.maxCharacters.toLocaleString()
                                                    color: shellRoot.textMutedTone
                                                    font.family: shellRoot.monoFontFamily
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                }

                                                Item { Layout.fillWidth: true }

                                                ActionCircle {
                                                    glyph: shellRoot.iconGlyph("close")
                                                    enabledButton: shellRoot.sourceText.length > 0
                                                    onClicked: shellRoot.setSourceText("")
                                                }

                                                ActionCircle {
                                                    glyph: shellRoot.iconGlyph("paste")
                                                    enabledButton: translateService.clipboardAvailable
                                                    onClicked: translateService.requestClipboardText()
                                                }

                                                ActionCircle {
                                                    glyph: shellRoot.iconGlyph("mic")
                                                    enabledButton: translateService.audioCaptureAvailable
                                                    onClicked: {
                                                        shellRoot.activeTab = 2;
                                                        if (!translateService.recording) {
                                                            translateService.startRecording();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    PillButton {
                                        width: parent.width
                                        text: translateService.translating ? "Translating..." : "Translate now"
                                        glyph: shellRoot.iconGlyph("translate")
                                        selected: true
                                        enabledButton: shellRoot.sourceText.trim().length > 0 && !translateService.translating && translateService.activeModel.length > 0
                                        onClicked: translateService.translateText(shellRoot.sourceText, shellRoot.sourceLanguage, shellRoot.targetLanguage)
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 240
                                        radius: 28
                                        color: shellRoot.deepTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 20
                                            spacing: 16

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: "Translation"
                                                        color: shellRoot.textPrimaryTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 18
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Text {
                                                        text: shellRoot.targetLanguage
                                                        color: shellRoot.textMutedTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 12
                                                    }
                                                }

                                                StatusChip {
                                                    label: translateService.translating ? "Live" : shellRoot.translationStatusText()
                                                    dotColor: translateService.translating ? shellRoot.accentTone : shellRoot.successTone
                                                }
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                text: translateService.translationError.length > 0
                                                    ? translateService.translationError
                                                    : (translateService.translatedText.length > 0
                                                        ? translateService.translatedText
                                                        : "Your translated output will appear here.")
                                                color: translateService.translationError.length > 0
                                                    ? shellRoot.errorTone
                                                    : Design.ThemePalette.mix(shellRoot.textPrimaryTone, shellRoot.accentTone, 0.1)
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: translateService.translatedText.length > 0 ? 24 : 18
                                                font.weight: Font.Medium
                                                wrapMode: Text.Wrap
                                                verticalAlignment: Text.AlignTop
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: translateService.lastTranslationModel.length > 0
                                                        ? ("Model: " + translateService.lastTranslationModel)
                                                        : "Waiting for a completed translation"
                                                    color: shellRoot.textMutedTone
                                                    font.family: shellRoot.monoFontFamily
                                                    font.pixelSize: 11
                                                }

                                                ActionCircle {
                                                    width: 40
                                                    height: 40
                                                    radius: 20
                                                    glyph: shellRoot.iconGlyph("volume")
                                                    enabledButton: translateService.translatedText.length > 0 && translateService.speechAvailable
                                                    onClicked: translateService.speak(translateService.translatedText, false)
                                                }

                                                ActionCircle {
                                                    width: 40
                                                    height: 40
                                                    radius: 20
                                                    glyph: shellRoot.iconGlyph("copy")
                                                    enabledButton: translateService.translatedText.length > 0 && translateService.clipboardAvailable
                                                    onClicked: translateService.copyText(translateService.translatedText)
                                                }

                                                ActionCircle {
                                                    width: 40
                                                    height: 40
                                                    radius: 20
                                                    glyph: shellRoot.iconGlyph("share")
                                                    enabledButton: translateService.translatedText.length > 0 && translateService.clipboardAvailable
                                                    onClicked: translateService.copyText(translateService.translatedText)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                visible: shellRoot.activeTab === 1
                                height: visible ? imageTabColumn.implicitHeight : 0

                                Column {
                                    id: imageTabColumn
                                    width: parent.width
                                    spacing: 20

                                    Rectangle {
                                        width: parent.width
                                        radius: 26
                                        color: shellRoot.cardTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone
                                        implicitHeight: imageSurfaceColumn.implicitHeight + 32

                                        Column {
                                            id: imageSurfaceColumn
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 16

                                            Rectangle {
                                                width: 48
                                                height: 48
                                                radius: 16
                                                color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.12)

                                                GlyphText {
                                                    anchors.centerIn: parent
                                                    text: shellRoot.iconGlyph("upload")
                                                    color: shellRoot.accentTone
                                                    font.pixelSize: 24
                                                }
                                            }

                                            Text {
                                                text: "Upload an image to translate"
                                                color: shellRoot.textPrimaryTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 18
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                width: parent.width
                                                text: "Import a receipt, menu, sign, or screenshot. OCR runs locally when tesseract is installed."
                                                color: shellRoot.textMutedTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 11
                                                wrapMode: Text.Wrap
                                            }

                                            RowLayout {
                                                width: parent.width
                                                spacing: 10

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: "Upload image"
                                                    glyph: shellRoot.iconGlyph("upload")
                                                    selected: true
                                                    enabledButton: translateService.filePickerAvailable
                                                    onClicked: translateService.pickImage()
                                                }

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: "Take screenshot"
                                                    glyph: shellRoot.iconGlyph("camera")
                                                    outlined: true
                                                    enabledButton: translateService.screenshotAvailable
                                                    onClicked: translateService.captureScreenshot()
                                                }
                                            }

                                            RowLayout {
                                                spacing: 8

                                                StatusChip {
                                                    label: "PNG, JPG, WEBP"
                                                    dotColor: shellRoot.accentTone
                                                }

                                                StatusChip {
                                                    label: "Private on device"
                                                    dotColor: shellRoot.successTone
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        visible: translateService.selectedImagePath.length > 0
                                        height: visible ? pendingPreviewColumn.implicitHeight + 32 : 0
                                        radius: 24
                                        color: shellRoot.deepTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone

                                        Column {
                                            id: pendingPreviewColumn
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 14

                                            Text {
                                                text: "Pending preview"
                                                color: shellRoot.textPrimaryTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }

                                            Rectangle {
                                                width: parent.width
                                                height: 150
                                                radius: 20
                                                color: shellRoot.cardTone
                                                clip: true

                                                Image {
                                                    anchors.fill: parent
                                                    source: translateService.selectedImagePath.length > 0 ? ("file://" + translateService.selectedImagePath) : ""
                                                    fillMode: Image.PreserveAspectCrop
                                                    cache: false
                                                }
                                            }

                                            Text {
                                                width: parent.width
                                                text: translateService.selectedImagePath
                                                color: shellRoot.textMutedTone
                                                font.family: shellRoot.monoFontFamily
                                                font.pixelSize: 10
                                                elide: Text.ElideMiddle
                                            }

                                            RowLayout {
                                                width: parent.width
                                                spacing: 10

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: translateService.ocrState === "running" ? "Running OCR..." : "Run OCR"
                                                    glyph: shellRoot.iconGlyph("ocr")
                                                    selected: true
                                                    enabledButton: translateService.selectedImagePath.length > 0 && translateService.ocrAvailable && translateService.ocrState !== "running"
                                                    onClicked: translateService.runOcr(shellRoot.imageSourceLanguage)
                                                }

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: "Clear"
                                                    glyph: shellRoot.iconGlyph("close")
                                                    outlined: true
                                                    enabledButton: true
                                                    onClicked: translateService.clearSelectedImage()
                                                }
                                            }

                                            Text {
                                                width: parent.width
                                                text: translateService.ocrMessage
                                                color: translateService.ocrState === "error" ? shellRoot.errorTone : shellRoot.textMutedTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 11
                                                wrapMode: Text.Wrap
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        radius: 24
                                        color: shellRoot.cardTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone
                                        implicitHeight: ocrReviewColumn.implicitHeight + 32

                                        Column {
                                            id: ocrReviewColumn
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 14

                                            Text {
                                                text: "Review extracted text"
                                                color: shellRoot.textPrimaryTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }

                                            TextArea {
                                                id: ocrOutput
                                                width: parent.width
                                                height: 150
                                                text: ""
                                                wrapMode: TextEdit.Wrap
                                                color: shellRoot.textPrimaryTone
                                                placeholderText: "OCR output will appear here after extraction."
                                                placeholderTextColor: shellRoot.textMutedTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 14
                                                background: Rectangle {
                                                    radius: 18
                                                    color: shellRoot.deepTone
                                                    border.width: 1
                                                    border.color: shellRoot.subtleBorderTone
                                                }
                                                onTextChanged: translateService.extractedText = text
                                            }

                                            RowLayout {
                                                width: parent.width
                                                spacing: 10

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: "Send to text tab"
                                                    glyph: shellRoot.iconGlyph("translate")
                                                    selected: true
                                                    enabledButton: translateService.extractedText.trim().length > 0
                                                    onClicked: {
                                                        shellRoot.setSourceText(translateService.extractedText);
                                                        shellRoot.activeTab = 0;
                                                    }
                                                }

                                                PillButton {
                                                    Layout.fillWidth: true
                                                    text: "Translate OCR"
                                                    glyph: shellRoot.iconGlyph("bolt")
                                                    outlined: true
                                                    enabledButton: translateService.extractedText.trim().length > 0 && translateService.activeModel.length > 0 && !translateService.translating
                                                    onClicked: {
                                                        shellRoot.setSourceText(translateService.extractedText);
                                                        shellRoot.activeTab = 0;
                                                        translateService.translateText(translateService.extractedText, shellRoot.imageSourceLanguage, shellRoot.imageTargetLanguage);
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        radius: 24
                                        color: shellRoot.deepTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone
                                        implicitHeight: explainerColumn.implicitHeight + 30

                                        Column {
                                            id: explainerColumn
                                            anchors.fill: parent
                                            anchors.margins: 15
                                            spacing: 12

                                            Repeater {
                                                model: [
                                                    "1  Upload or capture an image",
                                                    "2  Detect text locally with OCR",
                                                    "3  Review before translating"
                                                ]

                                                delegate: RowLayout {
                                                    required property var modelData
                                                    spacing: 10

                                                    Rectangle {
                                                        width: 24
                                                        height: 24
                                                        radius: 12
                                                        color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.16)

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: modelData[0]
                                                            color: shellRoot.accentTone
                                                            font.family: shellRoot.monoFontFamily
                                                            font.pixelSize: 11
                                                            font.weight: Font.Bold
                                                        }
                                                    }

                                                    Text {
                                                        text: modelData.slice(3)
                                                        color: shellRoot.textMutedTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 12
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                visible: shellRoot.activeTab === 2
                                height: visible ? audioTabColumn.implicitHeight : 0

                                    Column {
                                        id: audioTabColumn
                                        width: parent.width
                                        spacing: 20

                                        Rectangle {
                                            width: parent.width
                                            height: 54
                                            radius: 20
                                            color: shellRoot.cardTone
                                            border.width: 1
                                            border.color: shellRoot.subtleBorderTone

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16
                                                anchors.rightMargin: 12
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: shellRoot.audioSourceTypeLabel()
                                                        color: shellRoot.textMutedTone
                                                        font.family: shellRoot.monoFontFamily
                                                        font.pixelSize: 10
                                                        font.weight: Font.DemiBold
                                                    }

                                                    Text {
                                                        text: shellRoot.audioSourceSummary()
                                                        color: shellRoot.textPrimaryTone
                                                        font.family: shellRoot.uiFontFamily
                                                        font.pixelSize: 13
                                                        font.weight: Font.DemiBold
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                GlyphText {
                                                    text: shellRoot.iconGlyph("dropdown")
                                                    color: shellRoot.textMutedTone
                                                    font.pixelSize: 12
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    shellRoot.audioSourceMenuOpen = !shellRoot.audioSourceMenuOpen;
                                                    shellRoot.sourceMenuOpen = false;
                                                    shellRoot.targetMenuOpen = false;
                                                    shellRoot.modelMenuOpen = false;
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 128
                                        radius: 24
                                        color: shellRoot.deepTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 7

                                            Repeater {
                                                model: 28

                                                delegate: Rectangle {
                                                    required property int index

                                                    width: 3
                                                    height: {
                                                        const base = 16 + ((index * 11) % 80);
                                                        if (translateService.recording) {
                                                            return 24 + ((index * 17 + shellRoot.waveformTick * 9) % 72);
                                                        }
                                                        return base;
                                                    }
                                                    radius: 99
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, translateService.recording ? 0.95 : 0.52)
                                                }
                                            }
                                        }
                                    }

                                    Item {
                                        width: parent.width
                                        height: 108

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: translateService.recording ? 94 : 82
                                            height: width
                                            radius: width / 2
                                            color: Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, translateService.recording ? 0.22 : 0.14)
                                        }

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 64
                                            height: 64
                                            radius: 32
                                            color: shellRoot.accentSolidTone
                                            border.width: 1
                                            border.color: Design.ThemePalette.withAlpha(shellRoot.accentForegroundTone, 0.18)

                                            GlyphText {
                                                anchors.centerIn: parent
                                                text: shellRoot.iconGlyph("mic")
                                                color: shellRoot.accentForegroundTone
                                                font.pixelSize: 26
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: translateService.toggleRecording()
                                            }
                                        }
                                    }

                                            Text {
                                                width: parent.width
                                                horizontalAlignment: Text.AlignHCenter
                                                text: translateService.recording ? "Tap to stop live capture" : "Tap to start live capture"
                                                color: shellRoot.textPrimaryTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 15
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        text: translateService.audioMessage
                                        color: shellRoot.textMutedTone
                                        font.family: shellRoot.uiFontFamily
                                        font.pixelSize: 11
                                        wrapMode: Text.Wrap
                                    }

                                    Rectangle {
                                        width: parent.width
                                        radius: 24
                                        color: shellRoot.cardTone
                                        border.width: 1
                                        border.color: shellRoot.subtleBorderTone
                                        implicitHeight: transcriptColumn.implicitHeight + 30

                                        Column {
                                            id: transcriptColumn
                                            anchors.fill: parent
                                            anchors.margins: 15
                                            spacing: 14

                                            RowLayout {
                                                width: parent.width
                                                spacing: 8

                                                Rectangle {
                                                    width: 8
                                                    height: 8
                                                    radius: 4
                                                    color: shellRoot.successTone
                                                }

                                                Text {
                                                    text: "LIVE TRANSCRIPT"
                                                    color: shellRoot.successTone
                                                    font.family: shellRoot.monoFontFamily
                                                    font.pixelSize: 10
                                                    font.weight: Font.DemiBold
                                                }
                                            }

                                            Text {
                                                text: translateService.selectedAudioSourceName.length > 0
                                                    ? (shellRoot.audioSourceLanguage + " • " + translateService.selectedAudioSourceName)
                                                    : shellRoot.audioSourceLanguage
                                                color: shellRoot.textMutedTone
                                                font.family: shellRoot.monoFontFamily
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                width: parent.width
                                                text: translateService.transcriptSource.length > 0
                                                    ? translateService.transcriptSource
                                                    : "Live capture is backend-managed. Install a local ASR engine to populate transcript segments here."
                                                color: shellRoot.textPrimaryTone
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 14
                                                lineHeight: 1.625
                                                wrapMode: Text.Wrap
                                            }

                                            Rectangle {
                                                width: parent.width
                                                height: 1
                                                color: Design.ThemePalette.withAlpha(Design.ThemePalette.white, 0.05)
                                            }

                                            Text {
                                                text: shellRoot.audioTargetLanguage
                                                color: shellRoot.accentTone
                                                font.family: shellRoot.monoFontFamily
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                width: parent.width
                                                text: translateService.transcriptTarget.length > 0
                                                    ? translateService.transcriptTarget
                                                    : "Final translated audio segments will appear here once a local streaming ASR engine is connected."
                                                color: Design.ThemePalette.mix(shellRoot.textPrimaryTone, shellRoot.accentTone, 0.12)
                                                font.family: shellRoot.uiFontFamily
                                                font.pixelSize: 16
                                                font.weight: Font.Medium
                                                wrapMode: Text.Wrap
                                            }
                                        }
                                    }

                                    RowLayout {
                                        width: parent.width
                                        spacing: 10

                                        PillButton {
                                            Layout.fillWidth: true
                                            text: "Repeat last"
                                            glyph: shellRoot.iconGlyph("play")
                                            outlined: true
                                            enabledButton: translateService.translatedText.length > 0 && translateService.speechAvailable
                                            onClicked: translateService.speak(translateService.translatedText, false)
                                        }

                                        PillButton {
                                            Layout.fillWidth: true
                                            text: "Slow playback"
                                            glyph: shellRoot.iconGlyph("slow")
                                            outlined: true
                                            enabledButton: translateService.translatedText.length > 0 && translateService.speechAvailable
                                            onClicked: translateService.speak(translateService.translatedText, true)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: feedbackTitle.length > 0 ? feedbackColumn.implicitHeight + 18 : 0
                        radius: 18
                        color: feedbackKind === "error"
                            ? Design.ThemePalette.withAlpha(shellRoot.errorTone, 0.14)
                            : (feedbackKind === "warning"
                                ? Design.ThemePalette.withAlpha(shellRoot.warningTone, 0.14)
                                : Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.1))
                        border.width: feedbackTitle.length > 0 ? 1 : 0
                        border.color: feedbackKind === "error"
                            ? Design.ThemePalette.withAlpha(shellRoot.errorTone, 0.22)
                            : (feedbackKind === "warning"
                                ? Design.ThemePalette.withAlpha(shellRoot.warningTone, 0.22)
                                : Design.ThemePalette.withAlpha(shellRoot.accentSolidTone, 0.22))
                        visible: feedbackTitle.length > 0

                        Column {
                            id: feedbackColumn
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            Text {
                                text: shellRoot.feedbackTitle
                                color: shellRoot.textPrimaryTone
                                font.family: shellRoot.uiFontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: shellRoot.feedbackMessage
                                color: shellRoot.textMutedTone
                                font.family: shellRoot.uiFontFamily
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: shellRoot.deepTone
                        border.width: 1
                        border.color: shellRoot.subtleBorderTone

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: translateService.modelState === "ready"
                                        ? shellRoot.successTone
                                        : (translateService.modelState === "warming"
                                            ? shellRoot.accentTone
                                            : (translateService.modelState === "error"
                                                ? shellRoot.errorTone
                                                : shellRoot.textMutedTone))
                                }

                                Text {
                                    text: {
                                        if (translateService.modelState === "ready") return "Status: Ollama Active";
                                        if (translateService.modelState === "warming") return "Status: Loading model";
                                        if (translateService.modelState === "error") return "Status: Ollama error";
                                        return "Status: Ollama offline";
                                    }
                                    color: shellRoot.textPrimaryTone
                                    font.family: shellRoot.uiFontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                id: modelAnchor
                                Layout.preferredWidth: 170
                                Layout.fillHeight: true

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 14
                                    color: shellRoot.cardTone
                                    border.width: 1
                                    border.color: shellRoot.subtleBorderTone

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 6

                                        Text {
                                            Layout.fillWidth: true
                                            text: translateService.activeModel.length > 0 ? translateService.activeModel : "No model"
                                            color: shellRoot.textPrimaryTone
                                            font.family: shellRoot.monoFontFamily
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                        }

                                        GlyphText {
                                            text: shellRoot.iconGlyph("dropdown")
                                            color: shellRoot.textMutedTone
                                            font.pixelSize: 12
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            shellRoot.modelMenuOpen = !shellRoot.modelMenuOpen;
                                            shellRoot.sourceMenuOpen = false;
                                            shellRoot.targetMenuOpen = false;
                                        }
                                    }
                                }

                                ModelMenu {
                                    width: 220
                                    anchors.right: parent.right
                                    y: -implicitHeight - 10
                                    models: translateService.models
                                    selectedValue: translateService.activeModel
                                    visible: shellRoot.modelMenuOpen
                                    onValueSelected: modelName => {
                                        translateService.selectModel(modelName);
                                        shellRoot.modelMenuOpen = false;
                                    }
                                }
                            }

                        }
                    }
                }

                LanguageMenu {
                    id: sourceLanguageMenu
                    parent: contentFrame
                    width: 190
                    x: 0
                    y: 184
                    options: shellRoot.languageOptions
                    selectedValue: shellRoot.sourceLanguage
                    title: "SOURCE"
                    visible: shellRoot.sourceMenuOpen
                    onValueSelected: value => {
                        shellRoot.sourceLanguage = value;
                        if (value === shellRoot.targetLanguage && value !== "Auto") {
                            shellRoot.targetLanguage = "Portuguese (Brazil)";
                        }
                        shellRoot.sourceMenuOpen = false;
                    }
                }

                LanguageMenu {
                    id: targetLanguageMenu
                    parent: contentFrame
                    width: 190
                    x: shellRoot.targetMenuX()
                    y: 184
                    options: shellRoot.languageOptions.filter(language => language !== "Auto")
                    selectedValue: shellRoot.targetLanguage
                    title: "TARGET"
                    visible: shellRoot.targetMenuOpen
                    onValueSelected: value => {
                        shellRoot.targetLanguage = value;
                        if (shellRoot.sourceLanguage === value) {
                            shellRoot.sourceLanguage = "English";
                        }
                        shellRoot.targetMenuOpen = false;
                    }
                }

                LanguageMenu {
                    id: audioSourceMenu
                    parent: contentFrame
                    width: 240
                    x: shellRoot.audioSourceMenuX()
                    y: 184
                    options: translateService.audioSources.map(source => {
                        const prefix = source.type === "playback_monitor" ? "[Playback] " : "[Mic] ";
                        return prefix + source.name;
                    })
                    selectedValue: {
                        const source = translateService.selectedAudioSource();
                        if (!source) {
                            return "";
                        }

                        return (source.type === "playback_monitor" ? "[Playback] " : "[Mic] ") + source.name;
                    }
                    title: "AUDIO SOURCE"
                    visible: shellRoot.audioSourceMenuOpen
                    onValueSelected: value => {
                        const selectedIndex = audioSourceMenu.options.indexOf(value);
                        if (selectedIndex >= 0 && selectedIndex < translateService.audioSources.length) {
                            translateService.setSelectedAudioSource(String(translateService.audioSources[selectedIndex].id || ""));
                        }
                        shellRoot.audioSourceMenuOpen = false;
                    }
                }
            }
        }
    }
}
