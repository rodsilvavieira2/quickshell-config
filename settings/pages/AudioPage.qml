import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"
import "../services"

PageScaffold {
    id: root

    property var localAudioService: null

    readonly property var audioService: root.context?.audioService ?? localAudioService
    readonly property var sinks: audioService?.sinks ?? []
    readonly property var sources: audioService?.sources ?? []
    readonly property var streams: audioService?.streams ?? []
    readonly property var currentSink: audioService?.sink ?? null
    readonly property var currentSource: audioService?.source ?? null

    property bool spatialAudioEnabled: false

    title: "Audio & Sound"
    description: ""

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    function sinkName(node) {
        if (!node)
            return "Unknown output";
        return node.description || node.name || "Unknown output";
    }

    function sourceName(node) {
        if (!node)
            return "Unknown input";
        return node.description || node.name || "Unknown input";
    }

    function sinkModels() {
        const list = sinks || [];
        const result = [];

        for (let index = 0; index < list.length; index++) {
            result.push({
                label: sinkName(list[index]),
                value: list[index]
            });
        }

        return result;
    }

    function sourceModels() {
        const list = sources || [];
        const result = [];

        for (let index = 0; index < list.length; index++) {
            result.push({
                label: sourceName(list[index]),
                value: list[index]
            });
        }

        return result;
    }

    function findNodeIndex(list, target) {
        if (!list || !target)
            return 0;

        for (let index = 0; index < list.length; index++) {
            if (list[index] === target)
                return index;
        }

        return 0;
    }

    function streamIconName(stream) {
        const name = (audioService?.getStreamName ? audioService.getStreamName(stream) : (stream.applicationName || stream.description || stream.name || "")).toLowerCase();
        if (name.includes("browser") || name.includes("chrome") || name.includes("firefox"))
            return "globe";
        if (name.includes("music") || name.includes("spotify") || name.includes("player"))
            return "music";
        if (name.includes("system") || name.includes("event") || name.includes("notify") || name === "")
            return "bell";
        return "volume-2";
    }

    AudioService {
        id: fallbackAudioService
        Component.onCompleted: root.localAudioService = fallbackAudioService
    }

    component CustomSwitch: Item {
        id: switchRoot
        implicitWidth: 52
        implicitHeight: 32

        property bool checked: false
        signal toggled(bool checked)

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: switchRoot.checked ? Design.Tokens.color.primary : Design.Tokens.color.surfaceContainerHighest
            border.width: Design.Tokens.border.width.thin
            border.color: switchRoot.checked ? Design.Tokens.color.primary : Design.Tokens.color.outlineVariant

            Rectangle {
                width: 24
                height: 24
                radius: 12
                x: switchRoot.checked ? parent.width - width - 4 : 4
                y: 4
                color: switchRoot.checked ? Design.Tokens.color.primaryForeground : Design.Tokens.color.text.secondary

                Behavior on x {
                    NumberAnimation {
                        duration: Design.Tokens.motion.duration.fast
                        easing.type: Design.Tokens.motion.easing.standard
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: switchRoot.toggled(!switchRoot.checked)
        }
    }

    DS.Card {
        Layout.fillWidth: true
        padding: Design.Tokens.space.s24

        ColumnLayout {
            width: parent.width
            spacing: Design.Tokens.space.s24

            Text {
                text: "Output"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.title
                font.pixelSize: Design.Tokens.font.size.title
                font.weight: Design.Tokens.font.weight.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s12

                Text {
                    text: "Choose your output device"
                    color: Design.Tokens.color.text.secondary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.caption
                }

                DS.SelectField {
                    Layout.preferredWidth: 380
                    model: sinkModels()
                    currentIndex: findNodeIndex(sinks, currentSink)
                    onActivated: index => {
                        const target = sinks[index];
                        if (target && audioService?.setAudioSink)
                            audioService.setAudioSink(target);
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Design.Tokens.space.s4
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s16

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Master Volume"
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.body
                    }

                    Text {
                        text: Math.round(clamp(currentSink?.audio?.volume ?? 0) * 100) + "%"
                        color: Design.Tokens.color.text.secondary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.caption
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s16

                    DS.LucideIcon {
                        name: "volume-1"
                        color: Design.Tokens.color.text.primary
                        iconSize: 20
                    }

                    DS.Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: clamp(currentSink?.audio?.volume ?? 0)
                        onValueChanged: value => {
                            if (audioService?.setVolume)
                                audioService.setVolume(value);
                        }
                    }

                    DS.LucideIcon {
                        name: "volume-2"
                        color: Design.Tokens.color.text.primary
                        iconSize: 20
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Design.Tokens.space.s4
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s4

                    Text {
                        text: "Spatial Audio"
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.body
                    }

                    Text {
                        text: "Enhance sound formatting for compatible devices"
                        color: Design.Tokens.color.text.secondary
                        font.family: Design.Tokens.font.family.caption
                        font.pixelSize: Design.Tokens.font.size.caption
                    }
                }

                CustomSwitch {
                    checked: root.spatialAudioEnabled
                    onToggled: checked => root.spatialAudioEnabled = checked
                }
            }
        }
    }

    DS.Card {
        Layout.fillWidth: true
        padding: Design.Tokens.space.s24

        ColumnLayout {
            width: parent.width
            spacing: Design.Tokens.space.s24

            Text {
                text: "Input"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.title
                font.pixelSize: Design.Tokens.font.size.title
                font.weight: Design.Tokens.font.weight.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s12

                Text {
                    text: "Choose your input device"
                    color: Design.Tokens.color.text.secondary
                    font.family: Design.Tokens.font.family.body
                    font.pixelSize: Design.Tokens.font.size.caption
                }

                DS.SelectField {
                    Layout.preferredWidth: 380
                    model: sourceModels()
                    currentIndex: findNodeIndex(sources, currentSource)
                    onActivated: index => {
                        const target = sources[index];
                        if (target && audioService?.setAudioSource)
                            audioService.setAudioSource(target);
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Design.Tokens.space.s4
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s16

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Input Gain"
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.body
                    }

                    Text {
                        text: Math.round(clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0) * 100) + "%"
                        color: Design.Tokens.color.text.secondary
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.caption
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s16

                    DS.LucideIcon {
                        name: "mic"
                        color: Design.Tokens.color.text.primary
                        iconSize: 20
                    }

                    DS.Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0)
                        onValueChanged: value => {
                            if (audioService?.setSourceVolume)
                                audioService.setSourceVolume(value);
                        }
                    }
                }
            }
        }
    }

    DS.Card {
        Layout.fillWidth: true
        padding: Design.Tokens.space.s24

        ColumnLayout {
            width: parent.width
            spacing: Design.Tokens.space.s24

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s4

                Text {
                    text: "Volume Mixer"
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.title
                    font.pixelSize: Design.Tokens.font.size.title
                    font.weight: Design.Tokens.font.weight.medium
                }

                Text {
                    text: "Adjust volume for individual apps"
                    color: Design.Tokens.color.text.secondary
                    font.family: Design.Tokens.font.family.caption
                    font.pixelSize: Design.Tokens.font.size.caption
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s20

                Repeater {
                    model: streams

                    RowLayout {
                        required property var modelData

                        Layout.fillWidth: true
                        spacing: Design.Tokens.space.s16

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: Design.Tokens.color.surfaceContainerHighest

                            DS.LucideIcon {
                                anchors.centerIn: parent
                                name: root.streamIconName(modelData)
                                color: Design.Tokens.color.text.primary
                                iconSize: 18
                            }
                        }

                        Text {
                            Layout.preferredWidth: 160
                            text: audioService?.getStreamName ? audioService.getStreamName(modelData) : (modelData.applicationName || modelData.description || modelData.name || "Application")
                            color: Design.Tokens.color.text.primary
                            font.family: Design.Tokens.font.family.body
                            font.pixelSize: Design.Tokens.font.size.body
                            elide: Text.ElideRight
                        }

                        DS.Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 1
                            value: clamp(modelData.audio?.volume ?? 0)
                            onValueChanged: value => {
                                if (audioService?.setStreamVolume)
                                    audioService.setStreamVolume(modelData, value);
                            }
                        }

                        Text {
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(clamp(modelData.audio?.volume ?? 0) * 100) + "%"
                            color: Design.Tokens.color.text.secondary
                            font.family: Design.Tokens.font.family.body
                            font.pixelSize: Design.Tokens.font.size.caption
                        }
                    }
                }

                DS.FeedbackBlock {
                    Layout.fillWidth: true
                    visible: streams.length === 0
                    kind: "info"
                    title: "No active streams"
                    message: "Start audio playback in an app to expose per-stream mixer controls."
                }
            }
        }
    }
}
