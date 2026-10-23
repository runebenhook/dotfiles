pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    property int temperature: 3500

    function toggle() {
        if (root.enabled) {
            stopProc.running = true
        } else {
            startProc.command = [
                "bash",
                "-c",
                "pkill -x hyprsunset >/dev/null 2>&1 || true; hyprsunset -t " + root.temperature + " >/dev/null 2>&1 &"
            ]
            startProc.running = true
        }
    }

    Process {
        id: startProc
        onExited: stateProc.running = true
    }

    Process {
        id: stopProc
        command: ["bash", "-c", "pkill -x hyprsunset >/dev/null 2>&1 || true"]
        onExited: stateProc.running = true
    }

    Process {
        id: stateProc

        command: [
            "bash",
            "-c",
            "pgrep -x hyprsunset >/dev/null 2>&1 && echo on || echo off"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = text.trim() === "on"
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: stateProc.running = true
    }
}
