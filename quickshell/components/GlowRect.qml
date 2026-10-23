// components/GlowRect.qml — Reusable glow/halo wrapper
//
// Wraps any item with a soft colored glow using QtQuick.Effects'
// MultiEffect (Qt 6.5+, ships with qt6-declarative — no extra deps).
//
// Usage:
//   GlowRect {
//       glowColor: Colors.colAccent
//       active:    someToggle.active
//       anchors.fill: someToggle
//   }
//
// `active` toggles the glow on/off with a smooth fade. When inactive,
// the effect is fully disabled (opacity 0) so it costs nothing at
// render time.

import QtQuick
import QtQuick.Effects
import "../config"

Item {
    id: root

    property color glowColor: Colors.colAccent
    property bool  active:    false
    property real  intensity: 0.6     // 0–1, glow strength
    property real  spread:    24      // px, blur radius of the glow

    // The glow is rendered as a colored, blurred copy of a simple
    // rounded rectangle matching this item's geometry.
    Rectangle {
        id: glowSource
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color:  root.glowColor
        visible: false   // only used as MultiEffect source
    }

    MultiEffect {
        anchors.fill: parent
        source: glowSource
        blurEnabled: true
        blur: 1.0
        blurMax: root.spread
        brightness: 0.0
        saturation: 0.0
        opacity: root.active ? root.intensity : 0.0

        Behavior on opacity {
            NumberAnimation { duration: Sizes.animSlow; easing.type: Easing.OutQuad }
        }
    }
}
