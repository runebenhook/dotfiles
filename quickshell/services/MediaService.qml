pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool available: false
    property bool playing: false

    property string title: ""
    property string artist: ""
    property string player: ""

    property string artUrl: ""
    property string rawArtUrl: ""
    property string pendingArtUrl: ""

    property int artSlot: 0

    // Tiempo multimedia
    property real positionSeconds: 0
    property real lengthSeconds: 0
    property real progress: 0

    property string positionText: "0:00"
    property string lengthText: "0:00"

    function refresh() {
        if (!infoProc.running)
            infoProc.running = true

        if (!statusProc.running)
            statusProc.running = true
    }

    function refreshPosition() {
        if (!positionProc.running)
            positionProc.running = true
    }

    function playPause() {
        if (!playPauseProc.running)
            playPauseProc.running = true
    }

    function next() {
        if (!nextProc.running)
            nextProc.running = true
    }

    function previous() {
        if (!previousProc.running)
            previousProc.running = true
    }

    function seek(progressValue) {
    if (!root.available || root.lengthSeconds <= 0)
        return

    if (seekProc.running)
        return

    let value = progressValue

    if (value < 0)
        value = 0

    if (value > 1)
        value = 1

    let targetSeconds =
        root.lengthSeconds * value

    // Actualización visual inmediata
    root.positionSeconds = targetSeconds
    root.updateProgress()

    seekProc.command = [
        "playerctl",
        "position",
        targetSeconds.toString()
    ]

    seekProc.running = true
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0)
            return "0:00"

        let total = Math.floor(seconds)
        let minutes = Math.floor(total / 60)
        let secs = total % 60

        return minutes + ":" + (secs < 10 ? "0" : "") + secs
    }

    function updateProgress() {
        if (lengthSeconds > 0) {
            progress = positionSeconds / lengthSeconds

            if (progress < 0)
                progress = 0

            if (progress > 1)
                progress = 1
        } else {
            progress = 0
        }

        positionText = formatTime(positionSeconds)
        lengthText = formatTime(lengthSeconds)
    }

    function updateArtwork(url) {
        if (url === "") {
            rawArtUrl = ""
            artUrl = ""
            return
        }

        if (url === rawArtUrl)
            return

        rawArtUrl = url

        if (!url.startsWith("file://")) {
            artUrl = url
            return
        }

        let sourcePath = url.substring(7)

        try {
            sourcePath = decodeURIComponent(sourcePath)
        } catch (e) {
            console.log(
                "MediaService: no se pudo decodificar artUrl:",
                e
            )
        }

        artSlot = artSlot === 0 ? 1 : 0

        let destinationPath =
            "/tmp/quickshell-album-art-" + artSlot

        pendingArtUrl =
            "file://" + destinationPath

        artCopyProc.command = [
            "cp",
            "--",
            sourcePath,
            destinationPath
        ]

        if (!artCopyProc.running)
            artCopyProc.running = true
    }

    // ─────────────────────────────────────
    // Metadata
    // ─────────────────────────────────────

    Process {
        id: infoProc

        command: [
            "bash",
            "-c",
            "playerctl metadata --format '{{playerName}}␟{{title}}␟{{artist}}␟{{mpris:artUrl}}␟{{mpris:length}}' 2>/dev/null | head -1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()

                if (output === "") {
                    root.available = false
                    root.player = ""
                    root.title = ""
                    root.artist = ""
                    root.rawArtUrl = ""
                    root.artUrl = ""

                    root.positionSeconds = 0
                    root.lengthSeconds = 0
                    root.updateProgress()

                    return
                }

                let parts = output.split("␟")

                root.available = true

                root.player =
                    parts.length > 0 ? parts[0] : ""

                root.title =
                    parts.length > 1 ? parts[1] : ""

                root.artist =
                    parts.length > 2 ? parts[2] : ""

                let newArtUrl =
                    parts.length > 3
                    ? parts[3].trim()
                    : ""

                root.updateArtwork(newArtUrl)

                let lengthMicroseconds =
                    parts.length > 4
                    ? parseFloat(parts[4])
                    : 0

                if (!isNaN(lengthMicroseconds)) {
                    root.lengthSeconds =
                        lengthMicroseconds / 1000000.0
                } else {
                    root.lengthSeconds = 0
                }

                root.updateProgress()
            }
        }
    }

    // ─────────────────────────────────────
    // Artwork
    // ─────────────────────────────────────

    Process {
        id: artCopyProc

        command: ["true"]

        onExited: {
            root.artUrl =
                root.pendingArtUrl
        }
    }

    // ─────────────────────────────────────
    // Playing status
    // ─────────────────────────────────────

    Process {
        id: statusProc

        command: [
            "bash",
            "-c",
            "playerctl status 2>/dev/null | head -1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.playing =
                    text.trim() === "Playing"
            }
        }
    }

    // ─────────────────────────────────────
    // Current position
    // ─────────────────────────────────────

    Process {
        id: positionProc

        command: [
            "bash",
            "-c",
            "playerctl position 2>/dev/null | head -1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let value =
                    parseFloat(text.trim())

                if (!isNaN(value)) {
                    root.positionSeconds = value
                } else {
                    root.positionSeconds = 0
                }

                root.updateProgress()
            }
        }
    }

    // ─────────────────────────────────────
    // Controls
    // ─────────────────────────────────────

    Process {
        id: playPauseProc

        command: [
            "playerctl",
            "play-pause"
        ]

        onExited: {
            root.refresh()
            root.refreshPosition()
        }
    }

    Process {
    id: seekProc

    command: ["true"]

    onExited: {
        root.refreshPosition()
        }
    }

    Process {
        id: nextProc

        command: [
            "playerctl",
            "next"
        ]

        onExited: {
            root.positionSeconds = 0
            root.updateProgress()

            root.refresh()
            root.refreshPosition()
        }
    }

    Process {
        id: previousProc

        command: [
            "playerctl",
            "previous"
        ]

        onExited: {
            root.positionSeconds = 0
            root.updateProgress()

            root.refresh()
            root.refreshPosition()
        }
    }

    // ─────────────────────────────────────
    // Timers
    // ─────────────────────────────────────

    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered:
            root.refresh()
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.available

        onTriggered:
            root.refreshPosition()
    }

    Component.onCompleted: {
        root.refresh()
        root.refreshPosition()
    }
}
