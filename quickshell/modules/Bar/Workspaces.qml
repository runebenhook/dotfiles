// modules/Bar/Workspaces.qml — Hyprland workspace indicator

import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../../config"

Row {
    id: root
    spacing: Sizes.barSpacing / 2

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            width:  Sizes.wsSize
            height: Sizes.wsSize
            radius: Sizes.wsSize / 2

            // Active workspace gets accent color, others are muted
            color: modelData.active ? Colors.colAccent : Colors.colSurface

            Behavior on color {
                ColorAnimation { duration: Behavior.animDuration }
            }

            // Workspace number
            Text {
                anchors.centerIn: parent
                text:  modelData.id
                color: modelData.active ? Colors.colBg : Colors.colFgMuted
                font.pixelSize: Sizes.fontSm
                font.bold: modelData.active
            }

            // Click to switch
            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
