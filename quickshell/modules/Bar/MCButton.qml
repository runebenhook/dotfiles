// modules/Bar/MCButton.qml — Small circular icon button for MediaControl
// Reused for prev / play-pause / next

import QtQuick
import "../../config"

Rectangle {
    id: root

    property string icon:   ""
    property bool   accent: false   // highlight (play/pause button)

    signal clicked()

    width:  22
    height: 22
    radius: width / 2
    anchors.verticalCenter: parent.verticalCenter

    color: hovered
        ? Colors.withAlpha(Colors.colAccent, 0.20)
        : "transparent"

    property bool hovered: false

    Behavior on color { ColorAnimation { duration: Sizes.animDuration } }

    Text {
        anchors.centerIn: parent
        text:  root.icon
        color: root.accent ? Colors.colAccent : Colors.colFgMuted
        font.pixelSize: Sizes.fontMd
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onClicked: root.clicked()
    }
}
