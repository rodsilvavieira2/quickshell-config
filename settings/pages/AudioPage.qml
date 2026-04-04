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

    title: "Audio & Sound"
    description: "Choose the default output and input devices, then adjust live application streams."

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

    AudioService {
        id: fallbackAudioService
        Component.onCompleted: root.localAudioService = fallbackAudioService
    }

    PageSection {
        title: "Output"
        description: "Pick the default sink used by the shell and adjust its master volume."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.SelectRow {
                    Layout.fillWidth: true
                    title: "Output device"
                    subtitle: "Default speakers, headphones, or display audio sink."
                    model: sinkModels()
                    currentIndex: findNodeIndex(sinks, currentSink)
                    onActivated: index => {
                        const target = sinks[index];
                        if (target && audioService?.setAudioSink)
                            audioService.setAudioSink(target);
                    }
                }

                DS.SwitchRow {
                    Layout.fillWidth: true
                    title: "Mute output"
                    subtitle: currentSink?.audio?.muted ? "Muted" : "Audio is playing"
                    checked: currentSink?.audio?.muted ?? false
                    onToggled: checked => {
                        if (audioService?.toggleMute)
                            audioService.toggleMute();
                    }
                }

                DS.SliderRow {
                    Layout.fillWidth: true
                    title: "Master volume"
                    subtitle: sinkName(currentSink)
                    from: 0
                    to: 1
                    value: clamp(currentSink?.audio?.volume ?? 0)
                    valueText: Math.round(clamp(currentSink?.audio?.volume ?? 0) * 100) + "%"
                    onValueChanged: value => {
                        if (audioService?.setVolume)
                            audioService.setVolume(value);
                    }
                }
            }
        }
    }

    PageSection {
        title: "Input"
        description: "Choose the default microphone and control the active input gain."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.SelectRow {
                    Layout.fillWidth: true
                    title: "Input device"
                    subtitle: "Default microphone used by the shell and applications."
                    model: sourceModels()
                    currentIndex: findNodeIndex(sources, currentSource)
                    onActivated: index => {
                        const target = sources[index];
                        if (target && audioService?.setAudioSource)
                            audioService.setAudioSource(target);
                    }
                }

                DS.SwitchRow {
                    Layout.fillWidth: true
                    title: "Mute microphone"
                    subtitle: currentSource?.audio?.muted ? "Muted" : "Microphone available"
                    checked: currentSource?.audio?.muted ?? false
                    onToggled: checked => {
                        if (audioService?.toggleSourceMute)
                            audioService.toggleSourceMute();
                    }
                }

                DS.SliderRow {
                    Layout.fillWidth: true
                    title: "Input gain"
                    subtitle: sourceName(currentSource)
                    from: 0
                    to: 1
                    value: clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0)
                    valueText: Math.round(clamp(currentSource?.audio?.volume ?? audioService?.sourceVolume ?? 0) * 100) + "%"
                    onValueChanged: value => {
                        if (audioService?.setSourceVolume)
                            audioService.setSourceVolume(value);
                    }
                }
            }
        }
    }

    PageSection {
        title: "Volume mixer"
        description: "Adjust the active application streams without leaving the settings window."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                Repeater {
                    model: streams

                    DS.SliderRow {
                        required property var modelData

                        Layout.fillWidth: true
                        title: audioService?.getStreamName ? audioService.getStreamName(modelData) : (modelData.applicationName || modelData.description || modelData.name || "Application")
                        subtitle: modelData.audio?.muted ? "Muted" : "Live stream"
                        from: 0
                        to: 1
                        value: clamp(modelData.audio?.volume ?? 0)
                        valueText: Math.round(clamp(modelData.audio?.volume ?? 0) * 100) + "%"
                        onValueChanged: value => {
                            if (audioService?.setStreamVolume)
                                audioService.setStreamVolume(modelData, value);
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
