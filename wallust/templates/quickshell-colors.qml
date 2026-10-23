pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Fondos siempre basados en la parte oscura de la paleta
    readonly property color colBg: "{{background}}"
    readonly property color colBgAlt: "{{color0}}"
    readonly property color colSurface: "{{color0}}"

    // Texto
    readonly property color colFg: "{{foreground}}"
    readonly property color colFgMuted: "{{color7}}"

    // Colores dinámicos del wallpaper
    readonly property color colAccent: "{{color12}}"
    readonly property color colBlue: "{{color4}}"
    readonly property color colYellow: "{{color3}}"

    // Borde relacionado con el accent en vez de una superficie clara
    readonly property color colBorder: "{{color12}}"

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }
}
