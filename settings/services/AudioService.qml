import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Item {
    id: root

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        } else if (node.isStream && node.audio) {
            acc.streams.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: [],
        streams: []
    })

    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources
    readonly property list<PwNode> streams: nodes.streams

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0

    readonly property bool sourceMuted: (source && source.audio && !isNaN(source.audio.volume)) ? source.audio.muted : fallbackSourceMuted
    readonly property real sourceVolume: (source && source.audio && !isNaN(source.audio.volume)) ? source.audio.volume : fallbackSourceVolume

    property real fallbackSourceVolume: 0.5
    property bool fallbackSourceMuted: false

    Process {
        id: wpctlReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let str = text.trim();
                if (str.startsWith("Volume:")) {
                    let parts = str.split(" ");
                    let volStr = parts[1];
                    if (str.includes("[MUTED]")) {
                        root.fallbackSourceMuted = true;
                        volStr = volStr.replace("[MUTED]", "").trim();
                    } else {
                        root.fallbackSourceMuted = false;
                    }
                    root.fallbackSourceVolume = parseFloat(volStr);
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (source && source.audio && isNaN(source.audio.volume)) {
                wpctlReader.running = true;
            }
        }
    }

    function setVolume(newVolume) {
        if (sink && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1.0, newVolume));
        }
    }

    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    Process {
        id: wpctlWriter
        property string action: "vol"
        property real targetVol: 0
        property bool targetMute: false

        command: {
            if (action === "vol") {
                return ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", targetVol.toString()];
            } else {
                return ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", targetMute ? "1" : "0"];
            }
        }
    }

    function setSourceVolume(newVolume) {
        if (source && source.audio) {
            let clamped = Math.max(0, Math.min(1.0, newVolume));
            if (isNaN(source.audio.volume)) {
                root.fallbackSourceVolume = clamped;
                wpctlWriter.action = "vol";
                wpctlWriter.targetVol = clamped;
                wpctlWriter.running = true;
            } else {
                source.audio.muted = false;
                source.audio.volume = clamped;
            }
        }
    }

    function toggleSourceMute() {
        if (source && source.audio) {
            if (isNaN(source.audio.volume)) {
                root.fallbackSourceMuted = !root.fallbackSourceMuted;
                wpctlWriter.action = "mute";
                wpctlWriter.targetMute = root.fallbackSourceMuted;
                wpctlWriter.running = true;
            } else {
                source.audio.muted = !source.audio.muted;
            }
        }
    }

    function setAudioSink(newSink) {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource) {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function setStreamVolume(stream, newVolume) {
        if (stream && stream.audio) {
            stream.audio.muted = false;
            stream.audio.volume = Math.max(0, Math.min(1.0, newVolume));
        }
    }

    function toggleStreamMute(stream) {
        if (stream && stream.audio) {
            stream.audio.muted = !stream.audio.muted;
        }
    }

    function getStreamName(stream) {
        if (!stream) return "Unknown";
        return stream.applicationName || stream.description || stream.name || "Unknown Application";
    }

    PwObjectTracker {
        objects: {
            let arr = [];
            for (let i = 0; i < root.sinks.length; i++) arr.push(root.sinks[i]);
            for (let i = 0; i < root.sources.length; i++) arr.push(root.sources[i]);
            for (let i = 0; i < root.streams.length; i++) arr.push(root.streams[i]);
            return arr;
        }
    }
}
