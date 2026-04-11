//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

import "./services"
import "./shared/designsystem" as Design
import "./shared/ui" as DS

ShellRoot {
    id: shellRoot

    property bool panelOpen: false
    property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
    property string feedbackKind: "info"
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property string pendingSsid: ""
    property string pendingBssid: ""
    property string pendingPassword: ""
    property bool passwordDialogOpen: false
    property bool speedtestRunning: false
    property string speedtestOutput: ""

    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/network/scripts"

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
    }

    function resetPasswordDialog() {
        passwordDialogOpen = false;
        pendingSsid = "";
        pendingBssid = "";
        pendingPassword = "";
    }

    function networkSubtitle(network) {
        const details = [];
        details.push(networkService.signalLabel(network.strength));

        const band = networkService.frequencyBandLabel(network.frequency);
        if (band.length > 0) {
            details.push(band);
        }

        details.push(networkService.securityLabel(network.security));
        return details.join(" • ");
    }

    function networkStatus(network) {
        if (network.active) {
            return "Connected";
        }

        return networkService.hasSavedProfile(network.ssid) ? "Saved" : "";
    }

    function handleConnectionResult(ssid, bssid, result) {
        if (result.success) {
            shellRoot.showFeedback("success", "Connected", "Connected to " + ssid + ".");
            shellRoot.resetPasswordDialog();
            networkService.refreshAll();
            return;
        }

        if (result.needsPassword) {
            shellRoot.pendingSsid = ssid;
            shellRoot.pendingBssid = bssid || "";
            shellRoot.pendingPassword = "";
            shellRoot.passwordDialogOpen = true;
            shellRoot.showFeedback("info", "Password required", "Enter the password for " + ssid + ".");
            return;
        }

        shellRoot.showFeedback("error", "Connection failed", result.error && result.error.length > 0 ? result.error : ("Could not connect to " + ssid + "."));
    }

    function connectToAccessPoint(network) {
        networkService.connectToNetworkWithPasswordCheck(network.ssid, network.isSecure, result => {
            shellRoot.handleConnectionResult(network.ssid, network.bssid, result);
        }, network.bssid);
    }

    function submitPassword() {
        if (!pendingSsid || pendingSsid.length === 0) {
            return;
        }

        networkService.connectToNetwork(pendingSsid, pendingPassword, pendingBssid, result => {
            shellRoot.handleConnectionResult(pendingSsid, pendingBssid, result);
        });
    }

    function runSpeedtest() {
        if (speedtestRunning) {
            return;
        }

        speedtestRunning = true;
        speedtestOutput = "Running speedtest...";
        shellRoot.showFeedback("info", "Speedtest", "Running bandwidth test on the active connection.");
        speedtestProc.running = true;
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            networkService.refreshAll();
        } else {
            resetPasswordDialog();
        }
    }

    IpcHandler {
        target: "network"

        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }

        function open() {
            shellRoot.panelOpen = true;
        }

        function close() {
            shellRoot.panelOpen = false;
        }

        function openCategory(categoryId: string) {
            shellRoot.panelOpen = true;
        }
    }

    component SectionLabel: Text {
        Layout.fillWidth: true
        color: Design.Tokens.color.text.secondary
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Design.Tokens.font.size.small
        font.weight: Design.Tokens.font.weight.semibold
    }

    component NetworkListRow: Rectangle {
        id: listRow

        signal connectRequested()
        signal disconnectRequested()
        signal forgetRequested()

        property string iconName: "wifi"
        property string title: ""
        property string subtitle: ""
        property string statusText: ""
        property bool isConnected: false
        property bool isSaved: false
        property bool showForget: false
        property bool rowEnabled: true

        Layout.fillWidth: true
        implicitHeight: 84
        radius: 24
        color: isConnected
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.12)
            : Design.Tokens.color.surfaceContainerLow
        border.width: Design.Tokens.border.width.thin
        border.color: isConnected
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.28)
            : Design.Tokens.color.outlineVariant
        opacity: rowEnabled ? 1 : Design.Tokens.opacities.disabled

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Design.Tokens.space.s16
            anchors.rightMargin: Design.Tokens.space.s16
            spacing: Design.Tokens.space.s16

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 22
                color: Design.Tokens.color.surfaceContainerHighest

                DS.LucideIcon {
                    anchors.centerIn: parent
                    name: listRow.iconName
                    iconSize: 20
                    color: listRow.isConnected ? Design.Tokens.color.primary : Design.Tokens.color.text.secondary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s4

                Text {
                    text: listRow.title
                    color: Design.Tokens.color.text.primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Design.Tokens.font.size.body
                    font.weight: Design.Tokens.font.weight.semibold
                    elide: Text.ElideRight
                }

                Text {
                    text: listRow.subtitle
                    color: Design.Tokens.color.text.secondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Design.Tokens.font.size.label
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

            Text {
                visible: listRow.statusText.length > 0
                text: listRow.statusText
                color: listRow.isConnected ? Design.Tokens.color.primary : Design.Tokens.color.text.secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Design.Tokens.font.size.label
            }

            DS.Button {
                visible: !listRow.isConnected
                text: "Connect"
                variant: listRow.isSaved ? "secondary" : "primary"
                disabled: !listRow.rowEnabled
                onClicked: listRow.connectRequested()
            }

            DS.Button {
                visible: listRow.isConnected
                text: "Disconnect"
                variant: "secondary"
                onClicked: listRow.disconnectRequested()
            }

            DS.Button {
                visible: listRow.showForget
                text: "Forget"
                variant: "ghost"
                onClicked: listRow.forgetRequested()
            }
        }
    }

    PanelWindow {
        id: window

        screen: shellRoot.resolveScreen()
        color: "transparent"
        visible: shellRoot.panelOpen || contentFrame.opacity > 0

        WlrLayershell.namespace: "quickshell:network"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shellRoot.panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        NetworkService {
            id: networkService
        }

        Connections {
            target: networkService

            function onConnectionFailed(ssid) {
                shellRoot.showFeedback("error", "Connection failed", "Could not connect to " + ssid + ".");
            }
        }

        Process {
            id: speedtestProc

            command: ["bash", shellRoot.scriptsDir + "/run_speedtest.sh"]

            stdout: StdioCollector {
                id: speedtestStdout

                onStreamFinished: {
                    const textValue = text.trim();
                    if (textValue.length > 0) {
                        shellRoot.speedtestOutput = textValue;
                    }
                }
            }

            stderr: StdioCollector {
                id: speedtestStderr

                onStreamFinished: {
                    const textValue = text.trim();
                    if (textValue.length > 0) {
                        shellRoot.speedtestOutput = textValue;
                    }
                }
            }

            onExited: code => {
                shellRoot.speedtestRunning = false;

                if (code === 0) {
                    if (shellRoot.speedtestOutput.length === 0) {
                        shellRoot.speedtestOutput = "Speedtest finished without output.";
                    }
                    shellRoot.showFeedback("success", "Speedtest finished", "The bandwidth test completed.");
                    return;
                }

                if (shellRoot.speedtestOutput.length === 0) {
                    shellRoot.speedtestOutput = "Could not run the speedtest.";
                }
                shellRoot.showFeedback("error", "Speedtest failed", shellRoot.speedtestOutput);
            }
        }

        DS.OverlayScrim {
            anchors.fill: parent
            opacity: contentFrame.opacity
        }

        MouseArea {
            anchors.fill: parent
            enabled: shellRoot.panelOpen
            onClicked: shellRoot.panelOpen = false
        }

        FocusScope {
            id: contentFrame

            anchors.centerIn: parent
            width: Math.min(980, Math.max(760, (window.screen ? window.screen.width : 1440) - 96))
            height: Math.min(860, Math.max(620, (window.screen ? window.screen.height : 900) - 96))
            opacity: shellRoot.panelOpen ? 1 : 0
            scale: shellRoot.panelOpen ? 1 : 0.985
            focus: shellRoot.panelOpen

            Keys.onEscapePressed: {
                if (shellRoot.passwordDialogOpen) {
                    shellRoot.resetPasswordDialog();
                } else {
                    shellRoot.panelOpen = false;
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 34
                color: Design.Tokens.color.surface
                border.width: Design.Tokens.border.width.thin
                border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.76)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => { mouse.accepted = true; }
            }

            DS.Panel {
                anchors.fill: parent
                backgroundColor: Design.Tokens.color.surfaceContainerHigh
                radius: 34
                clipContent: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Design.Tokens.space.s16

                    DS.TopAppBar {
                        Layout.fillWidth: true
                        title: "Network"
                        subtitle: "Simple view with network selection, disable toggle, and speedtest."

                        DS.Button {
                            text: "Refresh"
                            variant: "secondary"
                            onClicked: {
                                networkService.refreshAll();
                                shellRoot.showFeedback("info", "Refreshing", "Requesting the latest network state.");
                            }
                        }

                        DS.Button {
                            text: "Close"
                            variant: "ghost"
                            onClicked: shellRoot.panelOpen = false
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: pageColumn.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: pageColumn
                            width: parent.width
                            spacing: Design.Tokens.space.s16

                            DS.FeedbackBlock {
                                Layout.fillWidth: true
                                kind: shellRoot.feedbackKind
                                title: shellRoot.feedbackTitle
                                message: shellRoot.feedbackMessage
                                visible: shellRoot.feedbackTitle.length > 0 || shellRoot.feedbackMessage.length > 0
                            }

                            DS.Card {
                                Layout.fillWidth: true
                                backgroundColor: Design.Tokens.color.surfaceContainer

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Design.Tokens.space.s12

                                    Text {
                                        text: networkService.overviewTitle()
                                        color: Design.Tokens.color.text.primary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.title
                                        font.weight: Design.Tokens.font.weight.semibold
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        text: networkService.overviewMessage()
                                        color: Design.Tokens.color.text.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.label
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        text: networkService.active && networkService.active.ssid
                                            ? "Current network: " + networkService.active.ssid
                                            : (networkService.activeEthernet ? "Current network: Ethernet" : "Current network: Offline")
                                        color: Design.Tokens.color.text.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.small
                                    }
                                }
                            }

                            SectionLabel {
                                text: "CONTROLS"
                            }

                            DS.SwitchRow {
                                Layout.fillWidth: true
                                title: "Networking"
                                subtitle: networkService.networkingEnabled
                                    ? networkService.wifiStatusText()
                                    : "All networking is disabled."
                                checked: networkService.networkingEnabled
                                onToggled: checked => {
                                    networkService.enableNetworking(checked, result => {
                                        if (result.success) {
                                            shellRoot.showFeedback("success", checked ? "Networking enabled" : "Networking disabled", checked ? "Network connections are available again." : "All network interfaces have been disabled.");
                                            networkService.refreshAll();
                                        } else {
                                            shellRoot.showFeedback("error", "Could not change networking", result.error && result.error.length > 0 ? result.error : "The request failed.");
                                        }
                                    });
                                }
                            }

                            SectionLabel {
                                text: "SPEEDTEST"
                            }

                            DS.Card {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Design.Tokens.space.s12

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Design.Tokens.space.s12

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: Design.Tokens.space.s4

                                            Text {
                                                text: "Connection speed"
                                                color: Design.Tokens.color.text.primary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.body
                                                font.weight: Design.Tokens.font.weight.semibold
                                            }

                                            Text {
                                                text: "Runs the first available command: speedtest, speedtest-cli, or fast."
                                                color: Design.Tokens.color.text.secondary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.label
                                                wrapMode: Text.Wrap
                                            }
                                        }

                                        DS.Button {
                                            text: speedtestRunning ? "Running..." : "Run"
                                            variant: "primary"
                                            disabled: speedtestRunning || !networkService.networkingEnabled || (!networkService.isConnected && !networkService.activeEthernet)
                                            onClicked: shellRoot.runSpeedtest()
                                        }

                                        DS.Button {
                                            text: "Clear"
                                            variant: "ghost"
                                            disabled: speedtestRunning || shellRoot.speedtestOutput.length === 0
                                            onClicked: shellRoot.speedtestOutput = ""
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: Math.max(96, speedtestText.implicitHeight + Design.Tokens.space.s16 * 2)
                                        radius: 24
                                        color: Design.Tokens.color.surfaceContainerLow
                                        border.width: Design.Tokens.border.width.thin
                                        border.color: Design.Tokens.color.outlineVariant

                                        Text {
                                            id: speedtestText
                                            anchors.fill: parent
                                            anchors.margins: Design.Tokens.space.s16
                                            text: shellRoot.speedtestOutput.length > 0 ? shellRoot.speedtestOutput : "No speedtest results yet."
                                            color: Design.Tokens.color.text.secondary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: Design.Tokens.font.size.label
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                            }

                            SectionLabel {
                                text: "AVAILABLE NETWORKS"
                            }

                            DS.Card {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Design.Tokens.space.s12

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Design.Tokens.space.s12

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: Design.Tokens.space.s4

                                            Text {
                                                text: "Wi-Fi selection"
                                                color: Design.Tokens.color.text.primary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.body
                                                font.weight: Design.Tokens.font.weight.semibold
                                            }

                                            Text {
                                                text: networkService.wifiEnabled
                                                    ? "Choose a network or disconnect from the current one."
                                                    : "Turn Wi-Fi back on to scan nearby networks."
                                                color: Design.Tokens.color.text.secondary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.label
                                                wrapMode: Text.Wrap
                                            }
                                        }

                                        DS.Button {
                                            text: "Enable Wi-Fi"
                                            variant: "secondary"
                                            visible: networkService.networkingEnabled && !networkService.wifiEnabled
                                            onClicked: {
                                                networkService.enableWifi(true, result => {
                                                    if (result.success) {
                                                        shellRoot.showFeedback("success", "Wi-Fi enabled", "Wireless scanning is available again.");
                                                        networkService.refreshAll();
                                                    } else {
                                                        shellRoot.showFeedback("error", "Could not enable Wi-Fi", result.error && result.error.length > 0 ? result.error : "The request failed.");
                                                    }
                                                });
                                            }
                                        }

                                        DS.Button {
                                            text: networkService.scanning ? "Scanning..." : "Rescan"
                                            variant: "ghost"
                                            disabled: networkService.scanning || !networkService.networkingEnabled || !networkService.wifiEnabled
                                            onClicked: {
                                                networkService.rescanWifi();
                                                shellRoot.showFeedback("info", "Scanning", "Looking for nearby Wi-Fi networks.");
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: !networkService.networkingEnabled
                                        text: "Networking is disabled."
                                        color: Design.Tokens.color.text.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.label
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: networkService.networkingEnabled && !networkService.wifiEnabled
                                        text: "Wi-Fi is currently turned off."
                                        color: Design.Tokens.color.text.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.label
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: networkService.networkingEnabled && networkService.wifiEnabled && networkService.networks.length === 0
                                        text: networkService.scanning ? "Scanning for networks..." : "No networks found."
                                        color: Design.Tokens.color.text.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Design.Tokens.font.size.label
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Design.Tokens.space.s10
                                        visible: networkService.networkingEnabled && networkService.wifiEnabled && networkService.networks.length > 0

                                        Repeater {
                                            model: networkService.networks

                                            delegate: NetworkListRow {
                                                required property var modelData

                                                title: modelData.ssid
                                                subtitle: shellRoot.networkSubtitle(modelData)
                                                statusText: shellRoot.networkStatus(modelData)
                                                isConnected: modelData.active
                                                isSaved: networkService.hasSavedProfile(modelData.ssid)
                                                showForget: !modelData.active && networkService.hasSavedProfile(modelData.ssid)
                                                rowEnabled: networkService.networkingEnabled && networkService.wifiEnabled

                                                onConnectRequested: shellRoot.connectToAccessPoint(modelData)
                                                onDisconnectRequested: {
                                                    networkService.disconnect(networkService.activeInterface, () => {
                                                        shellRoot.showFeedback("success", "Disconnected", "The active Wi-Fi connection has been disconnected.");
                                                        networkService.refreshAll();
                                                    });
                                                }
                                                onForgetRequested: {
                                                    networkService.forgetNetwork(modelData.ssid, result => {
                                                        if (result.success) {
                                                            shellRoot.showFeedback("success", "Network removed", "The saved profile for " + modelData.ssid + " was removed.");
                                                            networkService.refreshAll();
                                                        } else {
                                                            shellRoot.showFeedback("error", "Could not forget network", result.error && result.error.length > 0 ? result.error : "The request failed.");
                                                        }
                                                    });
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.minimumHeight: 8
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: shellRoot.passwordDialogOpen
                color: Qt.rgba(0, 0, 0, 0.38)
                z: 2

                onVisibleChanged: {
                    if (visible) {
                        passwordField.forceActiveFocus();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shellRoot.resetPasswordDialog()
                }

                DS.Card {
                    width: Math.min(460, parent.width - 64)
                    anchors.centerIn: parent
                    backgroundColor: Design.Tokens.color.surfaceContainerHighest

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => { mouse.accepted = true; }
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: Design.Tokens.space.s12

                        Text {
                            text: "Wi-Fi password"
                            color: Design.Tokens.color.text.primary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Design.Tokens.font.size.title
                            font.weight: Design.Tokens.font.weight.semibold
                        }

                        Text {
                            text: shellRoot.pendingSsid.length > 0
                                ? "Enter the password for " + shellRoot.pendingSsid + "."
                                : "Enter the network password."
                            color: Design.Tokens.color.text.secondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Design.Tokens.font.size.label
                            wrapMode: Text.Wrap
                        }

                        DS.TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            placeholderText: "Password"
                            text: shellRoot.pendingPassword
                            echoMode: TextInput.Password
                            onTextChanged: shellRoot.pendingPassword = text
                            onAccepted: shellRoot.submitPassword()
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Design.Tokens.space.s8

                            Item {
                                Layout.fillWidth: true
                            }

                            DS.Button {
                                text: "Cancel"
                                variant: "ghost"
                                onClicked: shellRoot.resetPasswordDialog()
                            }

                            DS.Button {
                                text: "Connect"
                                variant: "primary"
                                disabled: shellRoot.pendingPassword.length === 0
                                onClicked: shellRoot.submitPassword()
                            }
                        }
                    }
                }
            }
        }
    }
}
