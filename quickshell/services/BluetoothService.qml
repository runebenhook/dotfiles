pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    property bool scanning: false
    property bool busy: false

    property string statusMessage: ""
    property var devices: []

    // ─────────────────────────────────────
    // Power ON / OFF
    // ─────────────────────────────────────

    function toggle() {
        if (toggleProc.running)
            return

        if (root.enabled) {
            toggleProc.command = [
                "bash",
                "-c",
                "bluetoothctl power off"
            ]
        } else {
            toggleProc.command = [
                "bash",
                "-c",
                "rfkill unblock bluetooth && sleep 0.3 && bluetoothctl power on"
            ]
        }

        toggleProc.running = true
    }

    // ─────────────────────────────────────
    // Refresh
    // ─────────────────────────────────────

    function refresh() {
        if (!stateProc.running)
            stateProc.running = true

        if (root.enabled && !devicesProc.running)
            devicesProc.running = true
    }

    // ─────────────────────────────────────
    // Scan
    // ─────────────────────────────────────

    function scan() {
        if (!root.enabled || scanProc.running)
            return

        root.scanning = true
        root.statusMessage = "Buscando dispositivos..."

        scanProc.running = true
    }

    // ─────────────────────────────────────
    // Device actions
    // ─────────────────────────────────────

    function connectDevice(mac) {
        if (root.busy || mac === "")
            return

        root.busy = true
        root.statusMessage = "Conectando..."

        actionProc.command = [
            "bash",
            "-c",
            "bluetoothctl connect '" + mac + "'"
        ]

        actionProc.running = true
    }

    function disconnectDevice(mac) {
        if (root.busy || mac === "")
            return

        root.busy = true
        root.statusMessage = "Desconectando..."

        actionProc.command = [
            "bash",
            "-c",
            "bluetoothctl disconnect '" + mac + "'"
        ]

        actionProc.running = true
    }

    function pairDevice(mac) {
        if (root.busy || mac === "")
            return

        root.busy = true
        root.statusMessage = "Emparejando..."

        actionProc.command = [
            "bash",
            "-c",
            "bluetoothctl pair '" + mac + "' && " +
            "bluetoothctl trust '" + mac + "' && " +
            "bluetoothctl connect '" + mac + "'"
        ]

        actionProc.running = true
    }

    // ─────────────────────────────────────
    // State
    // ─────────────────────────────────────

    Process {
        id: stateProc

        command: [
            "bash",
            "-c",
            "bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled =
                    text.trim() === "yes"

                if (!root.enabled)
                    root.devices = []
            }
        }
    }

    // ─────────────────────────────────────
    // Devices
    // ─────────────────────────────────────

    Process {
        id: devicesProc

        command: [
            "bash",
            "-c",
            "bluetoothctl devices 2>/dev/null | while read -r word mac name; do " +
            "[ -z \"$mac\" ] && continue; " +
            "info=$(bluetoothctl info \"$mac\" 2>/dev/null); " +
            "paired=$(printf '%s\\n' \"$info\" | awk '/Paired:/{print $2; exit}'); " +
            "connected=$(printf '%s\\n' \"$info\" | awk '/Connected:/{print $2; exit}'); " +
            "trusted=$(printf '%s\\n' \"$info\" | awk '/Trusted:/{print $2; exit}'); " +
            "printf '%s␟%s␟%s␟%s␟%s\\n' \"$mac\" \"$name\" \"$paired\" \"$connected\" \"$trusted\"; " +
            "done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()
                let result = []

                if (output !== "") {
                    let lines = output.split("\n")

                    for (let i = 0; i < lines.length; ++i) {
                        let parts = lines[i].split("␟")

                        if (parts.length < 5)
                            continue

                        let mac = parts[0].trim()
                        let name = parts[1].trim()

                        if (mac === "")
                            continue

                        if (name === "")
                            name = mac

                        result.push({
                            mac: mac,
                            name: name,
                            paired: parts[2].trim() === "yes",
                            connected: parts[3].trim() === "yes",
                            trusted: parts[4].trim() === "yes"
                        })
                    }
                }

                // Connected first, then paired, then available.
                result.sort(function(a, b) {
                    if (a.connected && !b.connected)
                        return -1

                    if (!a.connected && b.connected)
                        return 1

                    if (a.paired && !b.paired)
                        return -1

                    if (!a.paired && b.paired)
                        return 1

                    return a.name.localeCompare(b.name)
                })

                root.devices = result
            }
        }
    }

    // ─────────────────────────────────────
    // Scan
    // ─────────────────────────────────────

    Process {
        id: scanProc

        command: [
            "bash",
            "-c",
            "bluetoothctl pairable on >/dev/null 2>&1; " +
            "timeout 7s bluetoothctl scan on >/dev/null 2>&1 || true; " +
            "bluetoothctl scan off >/dev/null 2>&1 || true"
        ]

        onExited: {
            root.scanning = false
            root.statusMessage = ""

            if (!devicesProc.running)
                devicesProc.running = true
        }
    }

    // ─────────────────────────────────────
    // Connect / disconnect / pair
    // ─────────────────────────────────────

    Process {
        id: actionProc
        command: ["true"]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()

                if (output !== "")
                    root.statusMessage = output
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                let output = text.trim()

                if (output !== "")
                    root.statusMessage = output
            }
        }

        onExited: {
            root.busy = false
            actionRefresh.restart()
        }
    }

    Timer {
        id: actionRefresh

        interval: 900
        repeat: false

        onTriggered: {
            root.statusMessage = ""
            root.refresh()
        }
    }

    // ─────────────────────────────────────
    // Power refresh
    // ─────────────────────────────────────

    Process {
        id: toggleProc
        command: ["true"]

        onExited: {
            toggleRefresh.restart()
        }
    }

    Timer {
        id: toggleRefresh

        interval: 700
        repeat: false

        onTriggered: root.refresh()
    }

    // Much less polling than before.
    Timer {
        interval: 15000
        repeat: true
        running: true

        onTriggered: {
            if (!stateProc.running)
                stateProc.running = true
        }
    }

    Component.onCompleted:
        root.refresh()
}
