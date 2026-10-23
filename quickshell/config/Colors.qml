pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Fondos siempre basados en la parte oscura de la paleta
    readonly property color colBg: "#000204"
    readonly property color colBgAlt: "#000204"
    readonly property color colSurface: "#000204"

    // Texto
    readonly property color colFg: "#FFFBDA"
    readonly property color colFgMuted: "#F6F1C1"

    // Colores dinámicos del wallpaper
    readonly property color colAccent: "#B3977F"
    readonly property color colBlue: "#B3977F"
    readonly property color colYellow: "#F64760"

    // Borde relacionado con el accent en vez de una superficie clara
    readonly property color colBorder: "#B3977F"

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }
}
