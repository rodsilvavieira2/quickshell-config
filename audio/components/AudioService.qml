import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        } else if (node.isStream && node.audio) {
            // Application streams (output streams)
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

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property bool sourceMuted: !!source?.audio?.muted
    readonly property real sourceVolume: source?.audio?.volume ?? 0

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

    function setSourceVolume(newVolume) {
        if (source && source.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1.0, newVolume));
        }
    }

    function toggleSourceMute() {
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted;
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