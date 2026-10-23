// modules/ControlCenter/CCSlider.qml
// Row: icon (tappable) + label + percentage + drag slider

import QtQuick
import QtQuick.Layouts
import "../../config"

ColumnLayout {
    id: root

    // ─── API ────────────────────────────────────────────────
    property string icon:      ""
    property string label:     ""
    property real   value:     50        // 0–100
    property color  iconColor: Colors.colAccent

    signal moved(real value)
    signal iconClicked()

    spacing: 6

    // ─── Top row: icon + label + percentage ─────────────────
    RowLayout {
        Layout.fillWidth: true

        Text {
            text:  root.icon
            color: root.iconColor
            font.pixelSize: Sizes.fontLg

            MouseArea {
                anchors.fill: parent
                onClicked: root.iconClicked()
            }
        }

        Text {
            text:  root.label
            color: Colors.colFg
            font.pixelSize: Sizes.fontSm
            Layout.fillWidth: true
        }

        Text {
            text:  Math.round(root.value) + "%"
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontSm
            horizontalAlignment: Text.AlignRight
        }
    }

    // ─── Track ──────────────────────────────────────────────
    Rectangle {
        id: track
        Layout.fillWidth: true
        height: 6
        radius: 3
        color:  Colors.colBgAlt

        // Fill
        Rectangle {
            id: fill
            width:  track.width * (root.value / 100)
            height: track.height
            radius: track.radius
            color:  root.iconColor

            Behavior on width {
                NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
            }
        }

        // Thumb
        Rectangle {
            id: thumb
            width:  14
            height: 14
            radius: 7
            color:  Colors.colFg
            x:      fill.width - width / 2
            anchors.verticalCenter: parent.verticalCenter

            Behavior on x {
                NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
            }
        }

        // Drag interaction
        MouseArea {
            anchors.fill: parent
            onPressed:  (mouse) => seek(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) seek(mouse.x) }

            function seek(mouseX) {
                var clamped = Math.max(0, Math.min(mouseX, track.width))
                root.value  = (clamped / track.width) * 100
                root.moved(root.value)
            }
        }
    }
}
