// modules/Bar/SystemStats.qml — CPU, RAM, Battery

import Quickshell
import Quickshell.Io
import QtQuick
import "../../config"

Row {
    id: root
    spacing: Sizes.barSpacing

    property string cpuText: "0"
    property string ramText: ""
    property string battText: ""

    // CPU
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "󰻠"
            color: Colors.colAccent
            font.pixelSize: Sizes.fontMd
        }

        Text {
            text: root.cpuText + "%"
            color: Colors.colFg
            font.pixelSize: Sizes.fontSm
        }
    }

    // RAM
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "󰍛"
            color: Colors.colBlue
            font.pixelSize: Sizes.fontMd
        }

        Text {
            text: root.ramText
            color: Colors.colFg
            font.pixelSize: Sizes.fontSm
        }
    }

    // Battery
    Row {
        spacing: 4
        visible: root.battText !== ""
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "󰁹"
            color: Colors.colGreen
            font.pixelSize: Sizes.fontMd
        }

        Text {
            text: root.battText + "%"
            color: Colors.colFg
            font.pixelSize: Sizes.fontSm
        }
    }

    Process {
        id: cpuProc
        command: [
            "bash",
            "-c",
            "top -bn1 | grep 'Cpu(s)' | awk '{print int($2+$4)}'"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuText = text.trim()
            }
        }
    }

    Process {
        id: ramProc
        command: [
            "bash",
            "-c",
            "free -h | awk '/^Mem:/{print $3\"/\"$2}'"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.ramText = text.trim()
            }
        }
    }

    Process {
        id: battProc
        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo ''"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.battText = text.trim()
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: cpuProc.running = true
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: ramProc.running = true
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: battProc.running = true
    }
}
