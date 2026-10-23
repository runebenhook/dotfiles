pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    property bool scanning: false
    property bool connecting: false

    property string activeSsid: ""
    property string statusMessage: ""

    property var networks: []
    property var knownSsids: []

    // ─────────────────────────────────────
    // Wi-Fi ON / OFF
    // ─────────────────────────────────────

    function toggle() {
        if (toggleProc.running)
            return

        toggleProc.command = [
            "nmcli",
            "radio",
            "wifi",
            root.enabled ? "off" : "on"
        ]

        toggleProc.running = true
    }

    // ─────────────────────────────────────
    // Refresh
    // ─────────────────────────────────────

    function refresh() {
        if (!wifiStateProc.running)
            wifiStateProc.running = true

        if (!knownProc.running)
            knownProc.running = true

        if (root.enabled && !scanProc.running)
            scanProc.running = true
    }

    function scan() {
        if (!root.enabled)
            return

        if (scanProc.running)
            return

        root.scanning = true
        scanProc.running = true
    }

    // ─────────────────────────────────────
    // Connect
    // ─────────────────────────────────────

    function connectNetwork(ssid, password) {
        if (ssid === "")
            return

        if (connectProc.running)
            return

        root.connecting = true
        root.statusMessage = "Conectando a " + ssid + "..."

        if (password !== "") {
            connectProc.command = [
                "nmcli",
                "device",
                "wifi",
                "connect",
                ssid,
                "password",
                password
            ]
        } else {
            connectProc.command = [
                "nmcli",
                "device",
                "wifi",
                "connect",
                ssid
            ]
        }

        connectProc.running = true
    }

    // ─────────────────────────────────────
    // Known networks
    // ─────────────────────────────────────

    function updateKnownNetworks() {
        let updated = []

        for (let i = 0; i < root.networks.length; ++i) {
            let net = root.networks[i]

            updated.push({
                ssid: net.ssid,
                signal: net.signal,
                security: net.security,
                active: net.active,
                known: root.knownSsids.indexOf(net.ssid) !== -1
            })
        }

        root.networks = updated
    }

    // ─────────────────────────────────────
    // Toggle process
    // ─────────────────────────────────────

    Process {
        id: toggleProc

        command: ["true"]

        onExited: {
            toggleDelay.restart()
        }
    }

    Timer {
        id: toggleDelay

        interval: 700
        repeat: false

        onTriggered: root.refresh()
    }

    // ─────────────────────────────────────
    // Wi-Fi state
    // ─────────────────────────────────────

    Process {
        id: wifiStateProc

        command: [
            "bash",
            "-c",
            "LC_ALL=C nmcli radio wifi 2>/dev/null"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = text.trim() === "enabled"

                if (!root.enabled) {
                    root.activeSsid = ""
                    root.networks = []
                }
            }
        }
    }

    // ─────────────────────────────────────
    // Known connections
    // ─────────────────────────────────────

    Process {
        id: knownProc

        command: [
            "bash",
            "-c",
            "LC_ALL=C nmcli -t --escape no -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2 == \"802-11-wireless\" {print $1}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()

                if (output === "") {
                    root.knownSsids = []
                } else {
                    root.knownSsids = output.split("\n")
                }

                root.updateKnownNetworks()
            }
        }
    }

    // ─────────────────────────────────────
    // Network scan
    // ─────────────────────────────────────

    Process {
        id: scanProc

        command: [
            "bash",
            "-c",
            "LC_ALL=C nmcli -t --escape no -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()
                let networkMap = {}

                root.activeSsid = ""

                if (output !== "") {
                    let lines = output.split("\n")

                    for (let i = 0; i < lines.length; ++i) {
                        let line = lines[i]

                        if (line.trim() === "")
                            continue

                        let parts = line.split(":")

                        if (parts.length < 4)
                            continue

                        let inUse = parts[0].trim()
                        let ssid = parts[1].trim()
                        let signal = parseInt(parts[2].trim())
                        let security = parts.slice(3).join(":").trim()

                        // Hidden networks
                        if (ssid === "")
                            continue

                        if (isNaN(signal))
                            signal = 0

                        let active = inUse === "*"

                        if (active)
                            root.activeSsid = ssid

                        let known =
                            root.knownSsids.indexOf(ssid) !== -1

                        // nmcli can return the same SSID multiple times.
                        // Keep the strongest access point.
                        if (
                            networkMap[ssid] === undefined ||
                            signal > networkMap[ssid].signal
                        ) {
                            networkMap[ssid] = {
                                ssid: ssid,
                                signal: signal,
                                security: security,
                                active: active,
                                known: known
                            }
                        } else if (active) {
                            networkMap[ssid].active = true
                        }
                    }
                }

                let result = []

                for (let key in networkMap)
                    result.push(networkMap[key])

                result.sort(function(a, b) {
                    if (a.active && !b.active)
                        return -1

                    if (!a.active && b.active)
                        return 1

                    return b.signal - a.signal
                })

                root.networks = result
                root.scanning = false
            }
        }
    }

    // ─────────────────────────────────────
    // Connect process
    // ─────────────────────────────────────

    Process {
        id: connectProc

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
            root.connecting = false
            connectRefreshDelay.restart()
        }
    }

    Timer {
        id: connectRefreshDelay

        interval: 1300
        repeat: false

        onTriggered: {
            root.statusMessage = ""
            root.refresh()
        }
    }

    // ─────────────────────────────────────
    // Periodic refresh
    // ─────────────────────────────────────

    Timer {
        interval: 15000
        repeat: true
        running: true

        onTriggered: {
            if (!wifiStateProc.running)
                wifiStateProc.running = true

            if (root.enabled && !scanProc.running)
                scanProc.running = true
        }
    }

    Component.onCompleted: root.refresh()
}
