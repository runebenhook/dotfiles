// modules/Bar/Bar.qml — Main status bar


import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../../config"
import "."

PanelWindow {
    id: root

    // Reference to ControlCenter panel (injected from shell.qml)
    property var ccPanel: null

    // ─── Layer Shell positioning ────────────────────────────
    anchors {
        top:   true
        left:  true
        right: true
    }
    height:    Sizes.barHeight
    exclusiveZone: height

    // ─── Background ─────────────────────────────────────────
    color: Colors.colBg

    // ─── Layout ─────────────────────────────────────────────
    Row {
        anchors.fill: parent
        anchors.leftMargin:  Sizes.barSpacing
        anchors.rightMargin: Sizes.barSpacing
        spacing: Sizes.barSpacing

        // Left — Workspaces
        Workspaces {
            anchors.verticalCenter: parent.verticalCenter
        }

        // Left-center — Media control (hidden + zero-width if no MPRIS player)
        MediaControl {
            anchors.verticalCenter: parent.verticalCenter
        }

        // Center — Clock (flexible spacer trick)
        Item { Layout.fillWidth: true }

        Clock {
            anchors.centerIn: parent
        }

        Item { Layout.fillWidth: true }

        // Right — System stats + CC toggle
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Sizes.barSpacing

            SystemStats {}

            // Control Center toggle button
            Rectangle {
                width:  28
                height: 28
                radius: Sizes.radius / 2
                anchors.verticalCenter: parent.verticalCenter
                color: ccPanel && ccPanel.open
                    ? Colors.withAlpha(Colors.colAccent, 0.20)
                    : "transparent"

                Behavior on color { ColorAnimation { duration: Sizes.animDuration } }

                Text {
                    anchors.centerIn: parent
                    text:  "󰍜"
                    color: ccPanel && ccPanel.open
                        ? Colors.colAccent
                        : Colors.colFgMuted
                    font.pixelSize: Sizes.fontLg

                    Behavior on color { ColorAnimation { duration: Sizes.animDuration } }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (ccPanel) ccPanel.toggle()
                }
            }
        }
    }
}
