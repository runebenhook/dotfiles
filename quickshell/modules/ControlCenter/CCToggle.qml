// modules/ControlCenter/CCToggle.qml
// Square pill toggle: icon + label, active/inactive state

import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../components"

Rectangle {
    id: root

    // ─── API ────────────────────────────────────────────────
    property string icon:        ""
    property string label:       ""
    property bool   active:      false
    property color  activeColor: Colors.colAccent

    signal clicked()
    signal iconClicked()

    // ─── Sizing ─────────────────────────────────────────────
    Layout.fillWidth: true
    height: 64
    radius: Sizes.radius

    color: active
        ? Colors.withAlpha(activeColor, 0.20)
        : Colors.colSurface

    border.color: active ? activeColor : Colors.colBorder
    border.width: 1

    Behavior on color       { ColorAnimation { duration: Sizes.animDuration } }
    Behavior on border.color { ColorAnimation { duration: Sizes.animDuration } }

    // ─── Glow halo behind active toggles ───────────────────────
    PulseGlow {
        anchors.fill: parent
        anchors.margins: -6
        active:    root.active
        glowColor: root.activeColor
        intensity: 0.45
        z: -1
    }


    // ─── Content ────────────────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  root.icon
            color: root.active ? root.activeColor : Colors.colFgMuted
            font.pixelSize: 22

            Behavior on color { ColorAnimation { duration: Sizes.animDuration } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  root.label
            color: root.active ? Colors.colFg : Colors.colFgMuted
            font.pixelSize: Sizes.fontXs

            Behavior on color { ColorAnimation { duration: Sizes.animDuration } }
        }
    }

    // ─── Interaction ────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
