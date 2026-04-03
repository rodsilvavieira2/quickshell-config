import QtQuick
import QtQuick.Layouts

import "../../audio/components" as AudioModule
import "../../shared/designsystem" as Design
import "../../shared/ui" as UI

Item {
    id: root

    property var context: null

    AudioModule.AudioService {
        id: localAudioService
    }

    readonly property var audioService: root.context?.audioService ?? localAudioService
    readonly property var sinks: audioService?.sinks ?? []
    readonly property var sources: audioService?.sources ?? []
    readonly property var streams: audioService?.streams ?? []
    readonly property var currentSink: audioService?.sink ?? null
    readonly property var currentSource: audioService?.source ?? null

    implicitWidth: 920
    implicitHeight: column.implicitHeight

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    function sinkName(node) {
        if (!node) return "Unknown output";
        return node.description || node.name || "Unknown output";
    }

    function sourceName(node) {
        if (!node) return "Unknown input";
        return node.description || node.name || "Unknown input";
    }

    function sinkModels() {
        const list = sinks || [];
        const result = [];
        for (let i = 0; i < list.length; i++) {
            result.push({ label: sinkName(list[i]), value: list[i] });
        }
        return result;
    }

    function sourceModels() {
        const list = sources || [];
        const result = [];
        for (let i = 0; i < list.length; i++) {
            result.push({ label: sourceName(list[i]), value: list[i] });
        }
        return result;
    }

    function findNodeIndex(list, target) {
        if (!list || !target) return 0;
        for (let i = 0; i < list.length; i++) {
            if (list[i] === target) {
                return i;
            }
        }
        return 0;
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Design.Tokens.space.s20

        UI.HeaderBlock {
            Layout.fillWidth: true
            title: "Audio"
            subtitle: "Control default inputs, outputs, and live stream volume"
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Default Devices"
                    subtitle: "Pick the active sink and source"
                }

                UI.SelectRow {
                    Layout.fillWidth: true
                    title: "Output device"
                    subtitle: "Default sink used by the shell and apps"
                    model: sinkModels()
                    currentIndex: findNodeIndex(sinks, currentSink)
                    onActivated: index => {
                        const target = sinks[index];
                        if (target && audioService?.setAudioSink) {
                            audioService.setAudioSink(target);
                        }
                    }
                }

                UI.SelectRow {
                    Layout.fillWidth: true
                    title: "Input device"
                    subtitle: "Default microphone used by the shell and apps"
                    model: sourceModels()
                    currentIndex: findNodeIndex(sources, currentSource)
                    onActivated: index => {
                        const target = sources[index];
                        if (target && audioService?.setAudioSource) {
                            audioService.setAudioSource(target);
                        }
                    }
                }
            }
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Volume"
                    subtitle: "Use the same direct controls exposed by PipeWire"
                }

                UI.SwitchRow {
                    Layout.fillWidth: true
                    title: "Mute output"
                    subtitle: currentSink?.audio?.muted ? "Muted" : "Audio is playing"
                    checked: currentSink?.audio?.muted ?? false
                    onToggled: checked => {
                        if (audioService?.toggleMute) {
                            audioService.toggleMute();
                        }
                    }
                }

                UI.SliderRow {
                    Layout.fillWidth: true
                    title: "Output volume"
                    subtitle: "Default sink volume"
                    from: 0
                    to: 1
                    value: clamp(currentSink?.audio?.volume ?? 0)
                    valueText: Math.round(clamp(currentSink?.audio?.volume ?? 0) * 100) + "%"
                    onValueChanged: value => {
                        if (audioService?.setVolume) {
                            audioService.setVolume(value);
                        }
                    }
                }

                UI.SwitchRow {
                    Layout.fillWidth: true
                    title: "Mute microphone"
                    subtitle: currentSource?.audio?.muted ? "Muted" : "Microphone available"
                    checked: currentSource?.audio?.muted ?? false
                    onToggled: checked => {
                        if (audioService?.toggleSourceMute) {
                            audioService.toggleSourceMute();
                        }
                    }
                }

                UI.SliderRow {
                    Layout.fillWidth: true
                    title: "Microphone gain"
                    subtitle: "Default source volume"
                    from: 0
                    to: 1
                    value: clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0)
                    valueText: Math.round(clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0) * 100) + "%"
                    onValueChanged: value => {
                        if (audioService?.setSourceVolume) {
                            audioService.setSourceVolume(value);
                        }
                    }
                }
            }
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Streams"
                    subtitle: "Currently active application streams"
                }

                Repeater {
                    model: streams

                    UI.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        title: modelData.applicationName || modelData.description || modelData.name || "Application"
                        subtitle: modelData.audio?.muted ? "Muted" : "Live stream"
                        valueText: modelData.audio?.volume !== undefined ? Math.round((modelData.audio.volume ?? 0) * 100) + "%" : ""
                    }
                }

                UI.FeedbackBlock {
                    Layout.fillWidth: true
                    kind: "info"
                    title: "Backend"
                    message: "This page reuses the existing PipeWire-backed `AudioService` and remains ready for adapter injection through `context`."
                }
            }
        }
    }
}
