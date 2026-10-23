// modules/Notifications/NotificationItem.qml

import QtQuick
import "../../config"
import "../../components"

Rectangle {
    id: root

    property string summary: ""
    property string body:    ""
    property string appName: ""
    property int    urgency: 1

    signal dismissed()

    width:  300
    height: col.implicitHeight + 20
    radius: Sizes.radius

    color: urgency === 2 ? Colors.colError : Colors.colSurface

    // ─── Glow for critical notifications ────────────────────
    PulseGlow {
        anchors.fill: parent
        anchors.margins: -6
        active:    urgency === 2
        glowColor: Colors.colRed
        intensity: 0.5
        pulseSpeed: 1.0
        z: -1
    }

    // ─── Slide-in animation ─────────────────────────────────
    transform: Translate { id: slideIn; x: 320 }
    Component.onCompleted: slideAnim.start()

    NumberAnimation {
        id: slideAnim
        target: slideIn
        property: "x"
        from: 320; to: 0
        duration: 250
        easing.type: Easing.OutCubic
    }

    // ─── Content ────────────────────────────────────────────
    Column {
        id: col
        anchors {
            left: parent.left; right: parent.right; top: parent.top
            margins: 12
        }
        spacing: 4

        // App name
        Text {
            text:  root.appName
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontXs
            font.bold: true
        }

        // Summary
        Text {
            text:  root.summary
            color: Colors.colFg
            font.pixelSize: Sizes.fontSm
            font.bold: true
            wrapMode: Text.WordWrap
            width: parent.width
        }

        // Body (optional)
        Text {
            visible: root.body !== ""
            text:    root.body
            color:   Colors.colFgMuted
            font.pixelSize: Sizes.fontSm
            wrapMode: Text.WordWrap
            width: parent.width
            maximumLineCount: 3
            elide: Text.ElideRight
        }
    }

    // ─── Dismiss on click ───────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }
}
