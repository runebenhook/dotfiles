// modules/OSD/OSD.qml — Volume & Brightness On-Screen Display

import Quickshell
import QtQuick
import QtQuick.Controls
import "../../config"

PanelWindow {
    id: root

anchors {
    bottom: true
}

margins {
    bottom: 48
}

    width:  260
    height: 56
    color:  "transparent"

    // Auto-hide after 1.5 s of inactivity
    visible: hideTimer.running

    // ─── Background pill ────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color:  Colors.colSurface

        Row {
            anchors.centerIn: parent
            spacing: 12

            // Icon (volume 󰕾 / brightness 󰃠)
            Text {
                id: osdIcon
                text:  "󰕾"
                color: Colors.colAccent
                font.pixelSize: 22
                anchors.verticalCenter: parent.verticalCenter
            }

            // Progress bar
            Rectangle {
                width:  160
                height: 6
                radius: 3
                color:  Colors.colBgAlt
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width:  parent.width * (osdValue / 100)
                    height: parent.height
                    radius: parent.radius
                    color:  Colors.colAccent

                    Behavior on width {
                        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                    }
                }
            }

            // Percentage label
            Text {
                id: osdLabel
                text:  osdValue + "%"
                color: Colors.colFg
                font.pixelSize: Sizes.fontSm
                width: 36
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ─── State ──────────────────────────────────────────────
    property int    osdValue: 0
    property string osdType:  "volume"   // "volume" | "brightness"

    // ─── Hide timer ─────────────────────────────────────────
    Timer {
        id: hideTimer
        interval: 1500
        repeat:   false
    }

    // ─── Public API ─────────────────────────────────────────
    function showVolume(val) {
        osdType  = "volume"
        osdValue = val
        osdIcon.text = val === 0 ? "󰖁" : "󰕾"
        hideTimer.restart()
    }

    function showBrightness(val) {
        osdType  = "brightness"
        osdValue = val
        osdIcon.text = "󰃠"
        hideTimer.restart()
    }
}
