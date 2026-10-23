// components/PulseGlow.qml — Animated pulsing glow ring
//
// Tries to use the custom GLSL shader (assets/shaders/pulseglow.frag,
// compiled to pulseglow.frag.qsb via `qsb`). If the compiled shader is
// not present — e.g. qsb wasn't run, or shadertools isn't installed —
// falls back to the static glow from GlowRect.qml. Either way, widgets
// using PulseGlow never crash or render nothing.
//
// Usage:
//   PulseGlow {
//       anchors.fill: someToggle
//       active:      someToggle.active
//       glowColor:   Colors.colAccent
//   }
//
// Compile the custom shader (optional, gives the animated ring effect):
//   qsb --glsl "100 es,120,150" -o assets/shaders/pulseglow.frag.qsb \
//       assets/shaders/pulseglow.frag

import QtQuick
import "."

Item {
    id: root

    property color glowColor: "#8aadf4"
    property bool  active:    false
    property real  intensity: 0.6
    property real  pulseSpeed: 0.6   // pulses per second

    readonly property url shaderUrl:
        Qt.resolvedUrl("../assets/shaders/pulseglow.frag.qsb")

    property bool _shaderAvailable: false

    // ─── Probe for the compiled shader once ────────────────────
    Component.onCompleted: {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root._shaderAvailable = (xhr.status === 200 || xhr.status === 0)
            }
        }
        try {
            xhr.open("GET", root.shaderUrl)
            xhr.send()
        } catch (e) {
            root._shaderAvailable = false
        }
    }

    // ─── Animated shader path ──────────────────────────────────
    Loader {
        anchors.fill: parent
        active: root._shaderAvailable && root.active
        sourceComponent: ShaderEffect {
            property real time: 0
            property real intensity:  root.intensity
            property real pulseSpeed: root.pulseSpeed
            property color glowColor: root.glowColor

            fragmentShader: root.shaderUrl

            NumberAnimation on time {
                from: 0; to: 1000
                duration: 1000000
                loops: Animation.Infinite
                running: root.active
            }
        }
    }

    // ─── Static fallback (no animation, but always works) ──────
    GlowRect {
        anchors.fill: parent
        visible:   !root._shaderAvailable
        active:    root.active
        glowColor: root.glowColor
        intensity: root.intensity
    }
}
