// services/BrightnessService.qml

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real brightness: 100

    function setBrightness(v) {
        var clamped = Math.max(1, Math.min(v, 100))
        root.brightness = clamped

        setBrightnessProc.command = [
            "brightnessctl",
            "set",
            Math.round(clamped) + "%"
        ]

        setBrightnessProc.running = true
    }

    Process {
        id: setBrightnessProc
    }

    Process {
        id: brightProc

        command: [
            "bash",
            "-c",
            "brightnessctl -m | awk -F, '{gsub(/%/,\"\",$4); print $4}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseFloat(text.trim())

                if (!isNaN(v))
                    root.brightness = v
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true

        onTriggered: {
            brightProc.running = true
        }
    }
}
