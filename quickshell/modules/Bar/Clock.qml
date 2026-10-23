// modules/Bar/Clock.qml — Date & time display

import Quickshell
import QtQuick
import "../../config"

Column {
    id: root
    spacing: 2

    // ─── Time ───────────────────────────────────────────────
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text:  Qt.formatTime(now.value, "HH:mm")
        color: Colors.colFg
        font.pixelSize: Sizes.fontMd
        font.bold: true
    }

    // ─── Date ───────────────────────────────────────────────
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text:  Qt.formatDate(now.value, "ddd dd MMM")
        color: Colors.colFgMuted
        font.pixelSize: Sizes.fontSm
    }

    // Ticker — updates every second
    SystemClock {
        id: now
        precision: SystemClock.Seconds
    }
}
