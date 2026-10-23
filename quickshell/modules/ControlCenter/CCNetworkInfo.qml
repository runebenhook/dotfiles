import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../config"

RowLayout {
    id: root
    spacing: 8

    property string ssid: ""
    property string localIp: ""

    RowLayout {
        spacing: 5
        Layout.fillWidth: true

        Text {
            text: "󰤨"
            color: root.ssid !== "" ? Colors.colBlue : Colors.colFgMuted
            font.pixelSize: Sizes.fontMd
        }

        Text {
            text: root.ssid !== "" ? root.ssid : "Disconnected"
            color: root.ssid !== "" ? Colors.colFg : Colors.colFgMuted
            font.pixelSize: Sizes.fontSm
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    RowLayout {
        spacing: 5

        Text {
            text: "󰩟"
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontMd
        }

        Text {
            text: root.localIp !== "" ? root.localIp : "—"
            color: Colors.colFgMuted
            font.pixelSize: Sizes.fontSm
        }
    }

    Process {
        id: ssidProc

        command: [
            "bash",
            "-c",
            "LC_ALL=C nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2- | head -1"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.ssid = text.trim()
            }
        }
    }

    Process {
        id: ipProc

        command: [
            "bash",
            "-c",
            "ip -4 addr show $(ip route | awk '/default/{print $5;exit}') 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.localIp = text.trim()
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true

        onTriggered: {
            if (!ssidProc.running)
                ssidProc.running = true
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: true

        onTriggered: {
            if (!ipProc.running)
                ipProc.running = true
        }
    }
}
