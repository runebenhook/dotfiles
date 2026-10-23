// services/AudioService.qml

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real volume: 50
    property bool muted: false

    function setVolume(v) {
        var clamped = Math.max(0, Math.min(v, 100))
        root.volume = clamped

        setVolumeProc.command = [
            "pactl",
            "set-sink-volume",
            "@DEFAULT_SINK@",
            Math.round(clamped) + "%"
        ]

        setVolumeProc.running = true
    }

    function toggleMute() {
        muteToggleProc.command = [
            "pactl",
            "set-sink-mute",
            "@DEFAULT_SINK@",
            "toggle"
        ]

        muteToggleProc.running = true
    }

    Process {
        id: setVolumeProc
    }

    Process {
        id: muteToggleProc

        onExited: {
            muteProc.running = true
        }
    }

    Process {
        id: volProc

        command: [
            "bash",
            "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/{gsub(/%/,\"\"); print $5; exit}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseFloat(text.trim())

                if (!isNaN(v))
                    root.volume = v
            }
        }
    }

    Process {
        id: muteProc

        command: [
            "bash",
            "-c",
            "pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.muted = text.trim() === "yes"
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered: {
            volProc.running = true
            muteProc.running = true
        }
    }
}
