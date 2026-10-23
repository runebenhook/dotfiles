// modules/Bar/MediaControl.qml — MPRIS media widget for the status bar
//
// Shows the current track (title — artist) plus prev/play-pause/next
// buttons. Hidden entirely when no MPRIS player is active.

import Quickshell
import QtQuick
import "../../config"
import "../../services"

Row {
    id: root

    spacing: 6

    // Hide the whole widget if no player is reachable
    visible: MediaService.available
    width:   visible ? implicitWidth : 0

    // ─── Previous ─────────────────────────────────────────────
    MCButton {
        icon: "󰒮"
        onClicked: MediaService.previous()
    }

    // ─── Play / Pause ───────────────────────────────────────────
    MCButton {
        icon: MediaService.playing ? "󰏤" : "󰐊"
        accent: true
        onClicked: MediaService.playPause()
    }

    // ─── Next ───────────────────────────────────────────────────
    MCButton {
        icon: "󰒭"
        onClicked: MediaService.next()
    }

    // ─── Track info (title — artist), truncated ─────────────────
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            var t = MediaService.title  || ""
            var a = MediaService.artist || ""
            if (t === "" && a === "") return ""
            if (a === "") return t
            return t + " — " + a
        }
        color: Colors.colFg
        font.pixelSize: Sizes.fontSm
        elide: Text.ElideRight

        // Cap width so a long track name can't push out other widgets
        width: Math.min(implicitWidth, 220)
    }
}
