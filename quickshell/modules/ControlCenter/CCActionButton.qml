// modules/ControlCenter/CCActionButton.qml
// Small action button used for power/reboot/logout

import QtQuick
import QtQuick.Layouts
import "../../config"

Rectangle {
    id: root

    property string icon:  ""
    property string label: ""

    signal clicked()

    Layout.fillWidth: true
    height: 44
    radius: Sizes.radius
    color:  hovered ? Colors.colSurface : Colors.colBgAlt
    border.color: Colors.colBorder
    border.width: 1

    property bool hovered: false

    Behavior on color { ColorAnimation { duration: Sizes.animDuration } }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  root.icon
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontMd
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  root.label
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontXs
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:  root.hovered = true
        onExited:   root.hovered = false
        onClicked:  root.clicked()
    }
}
