// config/Sizes.qml — Dimensions, spacing, animation

pragma Singleton
import QtQuick

QtObject {
    // ─── Bar ────────────────────────────────────────────────
    readonly property int barHeight:  40
    readonly property int barSpacing: 12

    // ─── Workspaces ─────────────────────────────────────────
    readonly property int wsSize: 22

    // ─── Typography ─────────────────────────────────────────
    readonly property int fontXs: 10
    readonly property int fontSm: 12
    readonly property int fontMd: 14
    readonly property int fontLg: 16

    // ─── Layout ─────────────────────────────────────────────
    readonly property int radius:  8
    readonly property int padding: 10

    // ─── Animations ─────────────────────────────────────────
    readonly property int animDuration: 150   // ms, color / opacity transitions
    readonly property int animSlow:     300   // ms, slide / resize transitions
}
