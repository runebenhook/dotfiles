// components/BlurPanel.qml — Reusable frosted-glass background
//
// Wraps panel content with a blurred, semi-transparent background using
// QtQuick.Effects' MultiEffect. Designed for ControlCenter / Notification
// panels to get a "frosted glass" look that still tints with the live
// pywal palette (via Colors.colSurface).
//
// Usage:
//   BlurPanel {
//       anchors.fill: parent
//       radius: Sizes.radius
//
//       // your content goes in the `content` property:
//       content: ColumnLayout { ... }
//   }

import QtQuick
import QtQuick.Effects
import "../config"

Item {
    id: root

    property real radius:     Sizes.radius
    property real blurAmount: 32      // px
    property real tintAlpha:  0.85    // 0–1, surface color opacity
    default property alias content: contentItem.data

    // ─── Background layer ────────────────────────────────────
    // A blurred copy of whatever sits visually behind this panel
    // is not accessible in QuickShell without ScreenCapture, so we
    // approximate "frosted glass" with a tinted, slightly blurred
    // solid layer — cheap and consistent across compositors.
    Rectangle {
        id: bgSource
        anchors.fill: parent
        radius: root.radius
        color:  Colors.withAlpha(Colors.colSurface, root.tintAlpha)
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: bgSource
        blurEnabled: true
        blur: 0.4
        blurMax: root.blurAmount
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color:  Colors.withAlpha(Colors.colSurface, root.tintAlpha)
        border.color: Colors.colBorder
        border.width: 1
    }

    // ─── Content slot ─────────────────────────────────────────
    Item {
        id: contentItem
        anchors.fill: parent
    }
}
