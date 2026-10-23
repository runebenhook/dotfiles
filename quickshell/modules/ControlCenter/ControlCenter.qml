import Quickshell
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import "../../config"
import "../../components"
import "../../services"
import "."

PanelWindow {
    id: root

    property bool open: false
    property bool wifiExpanded: false
    property bool bluetoothExpanded: false

    property string selectedWifiSsid: ""
    property string selectedWifiSecurity: ""
    property string wifiPassword: ""

    property string cpuProcText: "0%"
    property string ramProcText: "0%"
    property string batteryText: "--%"
    property int batteryPercent: 0
    property string batteryStatus: ""

    IpcHandler {
    target: "controlcenter"

    function toggle(): void {
        root.open = !root.open
    }

    function openPanel(): void {
        root.open = true
    }

    function closePanel(): void {
        root.open = false
    }

    function isOpen(): bool {
        return root.open
    }
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: 48
        right: 12
    }

    implicitWidth: 560
    implicitHeight: contentCol.implicitHeight + 24

    
    visible: open
    color: "transparent"

    // ─────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────

    function batteryIcon() {
        if (batteryStatus === "Charging")
            return "󰂄"

        if (batteryPercent >= 90)
            return "󰁹"
        if (batteryPercent >= 70)
            return "󰂀"
        if (batteryPercent >= 50)
            return "󰁾"
        if (batteryPercent >= 30)
            return "󰁼"
        if (batteryPercent >= 15)
            return "󰁺"

        return "󰂎"
    }

    function wifiIcon(signal) {
        if (signal >= 75)
            return "󰤨"

        if (signal >= 50)
            return "󰤥"

        if (signal >= 25)
            return "󰤢"

        return "󰤟"
    }

    function wifiSecured(security) {
        return security !== "" &&
               security !== "--" &&
               security !== "NONE"
    }

    function clearWifiSelection() {
        selectedWifiSsid = ""
        selectedWifiSecurity = ""
        wifiPassword = ""
    }

    // ─────────────────────────────────────
    // Main panel
    // ─────────────────────────────────────

    BlurPanel {
        anchors.fill: parent
        radius: 22
        tintAlpha: 0.60

        transform: Translate {
   	 y: root.open ? 0 : -6

   	 Behavior on y {
       		 NumberAnimation {
            duration: 120
             }
    	  }
	}

        Rectangle {
            anchors.fill: parent
            radius: 22

            color: Colors.withAlpha(
                Colors.colBg,
                0.10
            )

            border.width: 1
            border.color: Colors.withAlpha(
                Colors.colBorder,
                0.75
            )
        }

	Rectangle {
    	 anchors.fill: parent
   	 anchors.margins: 2

   	 radius: 20

   	 color: "transparent"

   	 border.width: 1

    	border.color: Colors.withAlpha(
        	Colors.colBlue,
        	0.10
   		 )
	}

        ColumnLayout {
            id: contentCol

            anchors {
                fill: parent
                margins: 12
            }

            spacing: 8

            // ═════════════════════════════
            // TOP BUTTONS
            // ═════════════════════════════

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Wi-Fi now opens the menu
                CCToggle {
                    Layout.fillWidth: true

                    icon: WifiService.enabled
                          ? "󰤨"
                          : "󰤭"

                    label: "Wi-Fi"

                    activeColor: Colors.colBlue
                    active: WifiService.enabled

                    onClicked: {
                        root.wifiExpanded =
                            !root.wifiExpanded

			if (root.wifiExpanded)
   			    root.bluetoothExpanded = false
			
                        root.clearWifiSelection()

                        if (
                            root.wifiExpanded &&
                            WifiService.enabled
                        ) {
                            WifiService.scan()
                        }
                    }
                }

               CCToggle {
   		 Layout.fillWidth: true

   		 icon: ""
   		 label: "Bluetooth"

   		 activeColor: Colors.colBlue
   		 active: BluetoothService.enabled

   		 onClicked: {
       			 root.bluetoothExpanded =
           		 !root.bluetoothExpanded

       		 // Si abrimos Bluetooth,
       		 // cerramos Wi-Fi para no hacer
       		 // el Control Center gigantesco.
       		 if (root.bluetoothExpanded) {
        	    root.wifiExpanded = false

           	 BluetoothService.refresh()

           	 if (BluetoothService.enabled)
               		 BluetoothService.scan()
       			 }
   		     }
		}

                CCToggle {
                    Layout.fillWidth: true

                    icon: "󰖔"
                    label: "Night"

                    activeColor: Colors.colYellow
                    active: NightService.enabled

                    onClicked:
                        NightService.toggle()
                }
            }

            // ═════════════════════════════
            // WI-FI DROPDOWN
            // ═════════════════════════════

            Rectangle {
                Layout.fillWidth: true

                Layout.preferredHeight:
                    root.wifiExpanded
                    ? (
                        root.selectedWifiSsid !== ""
                        ? 300
                        : 236
                    )
                    : 0

                visible: root.wifiExpanded

                radius: 14

                color: Colors.withAlpha(
                    Colors.colBgAlt,
                    0.94
                )

                border.width: 1

                border.color: Colors.withAlpha(
                    Colors.colBorder,
                    0.90
                )

                clip: true

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 10
                    }

                    spacing: 7

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        spacing: 8

                        Text {
                            text: "󰤨"

                            color: WifiService.enabled
                                   ? Colors.colBlue
                                   : Colors.colFgMuted

                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: WifiService.enabled
                                      ? (
                                          WifiService.activeSsid !== ""
                                          ? WifiService.activeSsid
                                          : "Wi-Fi"
                                      )
                                      : "Wi-Fi desactivado"

                                color: Colors.colFg
                                font.pixelSize: 12
                                font.bold: true

                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: WifiService.enabled
                                      ? "Redes disponibles"
                                      : "Enciende Wi-Fi para buscar redes"

                                color: Colors.colFgMuted
                                font.pixelSize: 9
                            }
                        }

                        // Refresh
                        Rectangle {
                            width: 30
                            height: 28
                            radius: 8

                            color:
                                wifiRefreshMouse.containsMouse
                                ? Colors.withAlpha(
                                      Colors.colSurface,
                                      1.0
                                  )
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text:
                                    WifiService.scanning
                                    ? "󰑓"
                                    : ""

                                color: Colors.colFgMuted
                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: wifiRefreshMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                enabled:
                                    WifiService.enabled &&
                                    !WifiService.scanning

                                onClicked:
                                    WifiService.scan()
                            }
                        }

                        // Power toggle
                        Rectangle {
                            width: 30
                            height: 28
                            radius: 8

                            color:
                                wifiPowerMouse.containsMouse
                                ? Colors.withAlpha(
                                      Colors.colSurface,
                                      1.0
                                  )
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: ""

                                color:
                                    WifiService.enabled
                                    ? Colors.colBlue
                                    : Colors.colFgMuted

                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: wifiPowerMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    root.clearWifiSelection()
                                    WifiService.toggle()
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1

                        color: Colors.withAlpha(
                            Colors.colBorder,
                            0.60
                        )
                    }

                    // Network list
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        visible: WifiService.enabled

                        clip: true

                        contentWidth: width
                        contentHeight: wifiNetworkColumn.height

                        boundsBehavior:
                            Flickable.StopAtBounds

                        Column {
                            id: wifiNetworkColumn

                            width: parent.width
                            spacing: 3

                            Repeater {
                                model: WifiService.networks

                                delegate: Rectangle {
                                    required property var modelData

                                    width:
                                        wifiNetworkColumn.width

                                    height: 38
                                    radius: 9

                                    color:
                                        modelData.active
                                        ? Colors.withAlpha(
                                              Colors.colAccent,
                                              0.16
                                          )
                                        : networkMouse.containsMouse
                                          ? Colors.withAlpha(
                                                Colors.colSurface,
                                                0.72
                                            )
                                          : "transparent"

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: 8
                                            rightMargin: 8
                                        }

                                        spacing: 8

                                        Text {
                                            text:
                                                root.wifiIcon(
                                                    modelData.signal
                                                )

                                            color:
                                                modelData.active
                                                ? Colors.colBlue
                                                : Colors.colFgMuted

                                            font.pixelSize: 15
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Text {
                                                Layout.fillWidth: true

                                                text:
                                                    modelData.ssid

                                                color:
                                                    modelData.active
                                                    ? Colors.colFg
                                                    : Colors.colFg

                                                font.pixelSize: 11

                                                font.bold:
                                                    modelData.active

                                                elide:
                                                    Text.ElideRight
                                            }

                                            Text {
                                                text:
                                                    modelData.active
                                                    ? "Conectado"
                                                    : modelData.known
                                                      ? "Guardada"
                                                      : root.wifiSecured(
                                                            modelData.security
                                                        )
                                                        ? "Protegida"
                                                        : "Abierta"

                                                color:
                                                    modelData.active
                                                    ? Colors.colBlue
                                                    : Colors.colFgMuted

                                                font.pixelSize: 8
                                            }
                                        }

                                        Text {
                                            visible:
                                                root.wifiSecured(
                                                    modelData.security
                                                )

                                            text: "󰌾"

                                            color: Colors.colFgMuted
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            text:
                                                modelData.signal + "%"

                                            color: Colors.colFgMuted
                                            font.pixelSize: 9
                                        }
                                    }

                                    MouseArea {
                                        id: networkMouse

                                        anchors.fill: parent
                                        hoverEnabled: true

                                        enabled:
                                            !modelData.active &&
                                            !WifiService.connecting

                                        onClicked: {
                                            if (
                                                modelData.active
                                            ) {
                                                return
                                            }

                                            // Known network:
                                            // let NetworkManager use
                                            // the saved password.
                                            if (
                                                modelData.known
                                            ) {
                                                root.clearWifiSelection()

                                                WifiService.connectNetwork(
                                                    modelData.ssid,
                                                    ""
                                                )

                                                return
                                            }

                                            // Open network
                                            if (
                                                !root.wifiSecured(
                                                    modelData.security
                                                )
                                            ) {
                                                root.clearWifiSelection()

                                                WifiService.connectNetwork(
                                                    modelData.ssid,
                                                    ""
                                                )

                                                return
                                            }

                                            // New protected network:
                                            // show password field.
                                            root.selectedWifiSsid =
                                                modelData.ssid

                                            root.selectedWifiSecurity =
                                                modelData.security

                                            root.wifiPassword = ""
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Wi-Fi disabled
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        visible: !WifiService.enabled

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                anchors.horizontalCenter:
                                    parent.horizontalCenter

                                text: "󰤭"

                                color: Colors.colFgMuted
                                font.pixelSize: 25
                            }

                            Text {
                                anchors.horizontalCenter:
                                    parent.horizontalCenter

                                text: "Wi-Fi desactivado"

                                color: Colors.colFgMuted
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Password box
                    Rectangle {
                        Layout.fillWidth: true

                        Layout.preferredHeight:
                            root.selectedWifiSsid !== ""
                            ? 58
                            : 0

                        visible:
                            root.selectedWifiSsid !== ""

                        radius: 10

                        color: Colors.withAlpha(
                            Colors.colSurface,
                            0.72
                        )

                        border.width: 1

                        border.color: Colors.withAlpha(
                            Colors.colBorder,
                            0.75
                        )

                        RowLayout {
                            anchors {
                                fill: parent
                                margins: 8
                            }

                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text:
                                        root.selectedWifiSsid

                                    color: Colors.colFg
                                    font.pixelSize: 10
                                    font.bold: true

                                    elide:
                                        Text.ElideRight
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 27

                                    radius: 7

                                    color:
                                        Colors.withAlpha(
                                            Colors.colBg,
                                            0.70
                                        )

                                    border.width: 1

                                    border.color:
                                        wifiPasswordInput.activeFocus
                                        ? Colors.withAlpha(
                                              Colors.colAccent,
                                              0.80
                                          )
                                        : Colors.withAlpha(
                                              Colors.colBorder,
                                              0.80
                                          )

                                    TextInput {
                                        id: wifiPasswordInput

                                        anchors {
                                            fill: parent
                                            leftMargin: 8
                                            rightMargin: 8
                                        }

                                        verticalAlignment:
                                            TextInput.AlignVCenter

                                        text:
                                            root.wifiPassword

                                        onTextChanged:
                                            root.wifiPassword =
                                                text

                                        echoMode:
                                            TextInput.Password

                                        color: Colors.colFg

                                        selectionColor:
                                            Colors.colAccent

                                        selectedTextColor:
                                            Colors.colBg

                                        font.pixelSize: 10

                                        clip: true
                                    }

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: 8
                                            verticalCenter:
                                                parent.verticalCenter
                                        }

                                        text: "Contraseña"

                                        color:
                                            Colors.colFgMuted

                                        font.pixelSize: 10

                                        visible:
                                            wifiPasswordInput.text === "" &&
                                            !wifiPasswordInput.activeFocus
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 76
                                Layout.preferredHeight: 32

                                radius: 9

                                color:
                                    wifiConnectMouse.containsMouse
                                    ? Colors.withAlpha(
                                          Colors.colAccent,
                                          0.34
                                      )
                                    : Colors.withAlpha(
                                          Colors.colAccent,
                                          0.22
                                      )

                                border.width: 1

                                border.color:
                                    Colors.withAlpha(
                                        Colors.colAccent,
                                        0.72
                                    )

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        WifiService.connecting
                                        ? "..."
                                        : "Conectar"

                                    color: Colors.colFg
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    id: wifiConnectMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    enabled:
                                        root.wifiPassword !== "" &&
                                        !WifiService.connecting

                                    onClicked: {
                                        WifiService.connectNetwork(
                                            root.selectedWifiSsid,
                                            root.wifiPassword
                                        )

                                        root.clearWifiSelection()
                                    }
                                }
                            }
                        }
                    }
                }
            }

 
	    // ═════════════════════════════
// BLUETOOTH DROPDOWN
// ═════════════════════════════

Rectangle {
    Layout.fillWidth: true

    Layout.preferredHeight:
        root.bluetoothExpanded
        ? 236
        : 0

    visible: root.bluetoothExpanded

    radius: 14

    color: Colors.withAlpha(
        Colors.colBgAlt,
        0.94
    )

    border.width: 1

    border.color: Colors.withAlpha(
        Colors.colBorder,
        0.90
    )

    clip: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 10
        }

        spacing: 7

        // ─────────────────────
        // Header
        // ─────────────────────

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            spacing: 8

            Text {
                text: ""

                color:
                    BluetoothService.enabled
                    ? Colors.colBlue
                    : Colors.colFgMuted

                font.pixelSize: 17
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text:
                        BluetoothService.enabled
                        ? "Bluetooth"
                        : "Bluetooth desactivado"

                    color: Colors.colFg
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    text:
                        BluetoothService.enabled
                        ? (
                            BluetoothService.scanning
                            ? "Buscando dispositivos..."
                            : "Dispositivos disponibles"
                        )
                        : "Enciende Bluetooth para buscar"

                    color: Colors.colFgMuted
                    font.pixelSize: 9
                }
            }

            // Refresh / scan
            Rectangle {
                width: 30
                height: 28
                radius: 8

                color:
                    bluetoothRefreshMouse.containsMouse
                    ? Colors.withAlpha(
                          Colors.colSurface,
                          1.0
                      )
                    : "transparent"

                Text {
                    anchors.centerIn: parent

                    text:
                        BluetoothService.scanning
                        ? "󰑓"
                        : ""

                    color:
                        BluetoothService.enabled
                        ? Colors.colFgMuted
                        : Colors.withAlpha(
                              Colors.colFgMuted,
                              0.35
                          )

                    font.pixelSize: 13
                }

                MouseArea {
                    id: bluetoothRefreshMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    enabled:
                        BluetoothService.enabled &&
                        !BluetoothService.scanning

                    onClicked:
                        BluetoothService.scan()
                }
            }

            // Power
            Rectangle {
                width: 30
                height: 28
                radius: 8

                color:
                    bluetoothPowerMouse.containsMouse
                    ? Colors.withAlpha(
                          Colors.colSurface,
                          1.0
                      )
                    : "transparent"

                Text {
                    anchors.centerIn: parent

                    text: ""

                    color:
                        BluetoothService.enabled
                        ? Colors.colBlue
                        : Colors.colFgMuted

                    font.pixelSize: 13
                }

                MouseArea {
                    id: bluetoothPowerMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked:
                        BluetoothService.toggle()
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: Colors.withAlpha(
                Colors.colBorder,
                0.60
            )
        }

        // ─────────────────────
        // Devices
        // ─────────────────────

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible:
                BluetoothService.enabled

            clip: true

            contentWidth: width
            contentHeight:
                bluetoothDeviceColumn.height

            boundsBehavior:
                Flickable.StopAtBounds

            Column {
                id: bluetoothDeviceColumn

                width: parent.width
                spacing: 3

                Repeater {
                    model:
                        BluetoothService.devices

                    delegate: Rectangle {
                        required property var modelData

                        width:
                            bluetoothDeviceColumn.width

                        height: 42
                        radius: 9

                        color:
                            modelData.connected
                            ? Colors.withAlpha(
                                  Colors.colAccent,
                                  0.16
                              )
                            : bluetoothDeviceMouse.containsMouse
                              ? Colors.withAlpha(
                                    Colors.colSurface,
                                    0.72
                                )
                              : "transparent"

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }

                            spacing: 9

                            // Device icon
                            Text {
                                text:
                                    modelData.connected
                                    ? "󰂱"
                                    : "󰂯"

                                color:
                                    modelData.connected
                                    ? Colors.colBlue
                                    : Colors.colFgMuted

                                font.pixelSize: 17
                            }

                            // Device info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true

                                    text:
                                        modelData.name

                                    color: Colors.colFg

                                    font.pixelSize: 11

                                    font.bold:
                                        modelData.connected

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    text:
                                        modelData.connected
                                        ? "Conectado"
                                        : modelData.paired
                                          ? "Emparejado"
                                          : "Disponible"

                                    color:
                                        modelData.connected
                                        ? Colors.colBlue
                                        : Colors.colFgMuted

                                    font.pixelSize: 8
                                }
                            }

                            // Action status
                            Text {
                                text:
                                    modelData.connected
                                    ? "Desconectar"
                                    : modelData.paired
                                      ? "Conectar"
                                      : "Emparejar"

                                color:
                                    modelData.connected
                                    ? Colors.colFgMuted
                                    : Colors.colBlue

                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: bluetoothDeviceMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            enabled:
                                !BluetoothService.busy

                            onClicked: {
                                if (
                                    modelData.connected
                                ) {
                                    BluetoothService
                                        .disconnectDevice(
                                            modelData.mac
                                        )

                                    return
                                }

                                if (
                                    modelData.paired
                                ) {
                                    BluetoothService
                                        .connectDevice(
                                            modelData.mac
                                        )

                                    return
                                }

                                BluetoothService
                                    .pairDevice(
                                        modelData.mac
                                    )
                            }
                        }
                    }
                }

                // No devices
                Item {
                    width:
                        bluetoothDeviceColumn.width

                    height:
                        BluetoothService.devices.length === 0
                        ? 100
                        : 0

                    visible:
                        BluetoothService.devices.length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "󰂯"

                            color:
                                Colors.colFgMuted

                            font.pixelSize: 24
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                BluetoothService.scanning
                                ? "Buscando..."
                                : "Sin dispositivos"

                            color:
                                Colors.colFgMuted

                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        // ─────────────────────
        // Bluetooth OFF
        // ─────────────────────

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible:
                !BluetoothService.enabled

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text: "󰂲"

                    color:
                        Colors.colFgMuted

                    font.pixelSize: 26
                }

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "Bluetooth desactivado"

                    color:
                        Colors.colFgMuted

                    font.pixelSize: 11
                }
            }
        }

        // Status
        Text {
            Layout.fillWidth: true

            visible:
                BluetoothService.statusMessage !== ""

            text:
                BluetoothService.statusMessage

            color:
                Colors.colFgMuted

            font.pixelSize: 8

            horizontalAlignment:
                Text.AlignHCenter

            elide:
                Text.ElideRight
        }
    }
}		

            // ═════════════════════════════
            // VOLUME + BRIGHTNESS
            // ═════════════════════════════

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                CCSlider {
                    Layout.fillWidth: true

                    icon:
                        AudioService.muted
                        ? "󰖁"
                        : "󰕾"

                    label: "Volume"
                    value: AudioService.volume

                    onValueChanged:
                        AudioService.setVolume(value)
                }

                CCSlider {
                    Layout.fillWidth: true

                    icon: "󰃠"
                    label: "Brightness"

                    value:
                        BrightnessService.brightness

                    onValueChanged:
                        BrightnessService.setBrightness(
                            value
                        )
                }
            }

            // ═════════════════════════════
            // CPU | RAM | BAT
            // ═════════════════════════════

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    radius: 12

                    color: Colors.withAlpha(
                        Colors.colSurface,
                        0.92
                    )

                    border.width: 1

                    border.color:
                        Colors.withAlpha(
                            Colors.colBorder,
                            0.82
                        )

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "󰻠  CPU"

                            color: Colors.colAccent
                            font.pixelSize: 13
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: root.cpuProcText

                            color: Colors.colFg
                            font.pixelSize: 17
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    radius: 12

                    color: Colors.withAlpha(
                        Colors.colSurface,
                        0.92
                    )

                    border.width: 1

                    border.color:
                        Colors.withAlpha(
                            Colors.colBorder,
                            0.82
                        )

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "󰍛  RAM"

                            color: Colors.colBlue
                            font.pixelSize: 13
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: root.ramProcText

                            color: Colors.colFg
                            font.pixelSize: 17
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    radius: 12

                    color: Colors.withAlpha(
                        Colors.colSurface,
                        0.92
                    )

                    border.width: 1

                    border.color:
                        Colors.withAlpha(
                            Colors.colBorder,
                            0.82
                        )

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                root.batteryIcon() +
                                "  BAT"

                            color:
                                root.batteryStatus ===
                                "Charging"
                                ? Colors.colYellow
                                : Colors.colBlue

                            font.pixelSize: 13
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: root.batteryText

                            color: Colors.colFg
                            font.pixelSize: 17
                            font.bold: true
                        }
                    }
                }
            }

            // ═════════════════════════════
            // NETWORK INFO
            // ═════════════════════════════

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38

                radius: 11

                color: Colors.withAlpha(
                    Colors.colBgAlt,
                    0.84
                )

                border.width: 1

                border.color:
                    Colors.withAlpha(
                        Colors.colBorder,
                        0.78
                    )

                CCNetworkInfo {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                }
            }

            // ═════════════════════════════
            // POWER
            // ═════════════════════════════

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Rectangle {
                        width: 42
                        height: 34
                        radius: 10

                        color:
                            powerMouse.containsMouse
                            ? Colors.withAlpha(
                                  Colors.colSurface,
                                  0.98
                              )
                            : Colors.withAlpha(
                                  Colors.colBgAlt,
                                  0.72
                              )

                        border.width: 1
                        border.color: Colors.colBorder

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: Colors.colFg
                            font.pixelSize: 17
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked:
                                poweroffProc.running = true
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 34
                        radius: 10

                        color:
                            rebootMouse.containsMouse
                            ? Colors.withAlpha(
                                  Colors.colSurface,
                                  0.98
                              )
                            : Colors.withAlpha(
                                  Colors.colBgAlt,
                                  0.72
                              )

                        border.width: 1
                        border.color: Colors.colBorder

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: Colors.colFg
                            font.pixelSize: 17
                        }

                        MouseArea {
                            id: rebootMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked:
                                rebootProc.running = true
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 34
                        radius: 10

                        color:
                            logoutMouse.containsMouse
                            ? Colors.withAlpha(
                                  Colors.colSurface,
                                  0.98
                              )
                            : Colors.withAlpha(
                                  Colors.colBgAlt,
                                  0.72
                              )

                        border.width: 1
                        border.color: Colors.colBorder

                        Text {
                            anchors.centerIn: parent
                            text: "󰍃"
                            color: Colors.colFg
                            font.pixelSize: 17
                        }

                        MouseArea {
                            id: logoutMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked:
                                logoutProc.running = true
                        }
                    }
                }
            }

            // ═════════════════════════════
            // MEDIA
            // ═════════════════════════════
           
            Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 140

    radius: 16

    color: Colors.withAlpha(
        Colors.colSurface,
        0.94
    )

    border.width: 1

    border.color:
        Colors.withAlpha(
            Colors.colBorder,
            0.86
        )

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12

        spacing: 14

        // ─────────────────────────
        // Album cover
        // ─────────────────────────

        Item {
    Layout.preferredWidth: 96
    Layout.preferredHeight: 96

    // Imagen original, oculta
    Image {
        id: albumImage

        anchors.fill: parent

        source: MediaService.artUrl

        fillMode: Image.PreserveAspectCrop

        visible: false

        cache: false
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Máscara redondeada
    Rectangle {
        id: albumMask

        anchors.fill: parent

        radius: 22

        visible: false

        color: "white"
    }

    // Imagen ya recortada
    OpacityMask {
        anchors.fill: parent

        source: albumImage
        maskSource: albumMask

        visible:
            MediaService.artUrl !== ""
    }

    // Borde exterior
    Rectangle {
        anchors.fill: parent

        radius: 22
        color: "transparent"

        border.width: 1
        border.color:
            Colors.withAlpha(
                Colors.colBorder,
                0.85
            )

        visible:
            MediaService.artUrl !== ""
    }

    // Placeholder
    Rectangle {
        anchors.fill: parent

        radius: 24

        color:
            Colors.withAlpha(
                Colors.colBgAlt,
                0.95
            )

        border.width: 1
        border.color:
            Colors.withAlpha(
                Colors.colBorder,
                0.85
            )

        visible:
            MediaService.artUrl === ""

        Text {
            anchors.centerIn: parent

            text: ""

            color:
                Colors.colFgMuted

            font.pixelSize: 28
        }
    }
}

        // ─────────────────────────
        // Media information
        // ─────────────────────────

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 4

            Text {
                Layout.fillWidth: true

                text:
                    MediaService.available
                    ? MediaService.title
                    : "Sin reproducción"

                color: Colors.colFg

                font.pixelSize: 15
                font.bold: true

                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true

                text:
                    MediaService.available
                    ? MediaService.artist
                    : "YouTube Music"

                color:
                    Colors.colFgMuted

                font.pixelSize: 11

                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Item {
                Layout.preferredHeight: 4
            }

            // ─────────────────────────
            // Progress bar
            // ─────────────────────────

            Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 14

    Rectangle {
        id: mediaProgressBar

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        height: mediaProgressMouse.containsMouse ? 6 : 5
        radius: height / 2

        color:
            Colors.withAlpha(
                Colors.colBg,
                0.78
            )

        // Progreso
        Rectangle {
            width:
                parent.width *
                MediaService.progress

            height:
                parent.height

            radius:
                parent.radius

            color:
                Colors.colAccent

            Behavior on width {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        // Punto indicador
        Rectangle {
            width:
                mediaProgressMouse.containsMouse
                ? 12
                : 9

            height: width
            radius: width / 2

            x: Math.max(
                0,
                Math.min(
                    mediaProgressBar.width - width,
                    mediaProgressBar.width *
                    MediaService.progress -
                    width / 2
                )
            )

            anchors.verticalCenter:
                parent.verticalCenter

            color:
                Colors.colFg

            border.width: 2
            border.color:
                Colors.colAccent

            opacity:
                MediaService.available
                ? 1
                : 0

            Behavior on width {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        MouseArea {
    id: mediaProgressMouse

    anchors {
        fill: parent
        topMargin: -5
        bottomMargin: -5
    }

    hoverEnabled: true

    enabled:
        MediaService.available &&
        MediaService.lengthSeconds > 0

    cursorShape:
        Qt.PointingHandCursor

    function seekFromMouse(mouseX) {
        let ratio = mouseX / width

        if (ratio < 0)
            ratio = 0

        if (ratio > 1)
            ratio = 1

       		 MediaService.seek(ratio)
   	 }

   	 onClicked: mouse => {
       		 seekFromMouse(mouse.x)
   	 }

   	 onPositionChanged: mouse => {
       	 if (pressed)
           	 seekFromMouse(mouse.x)
   	 }
      } 
   }
}

            // ─────────────────────────
            // Time
            // ─────────────────────────

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:
                        MediaService.positionText

                    color:
                        Colors.colFgMuted

                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text:
                        MediaService.lengthText

                    color:
                        Colors.colFgMuted

                    font.pixelSize: 9
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // ─────────────────────────
            // Media controls
            // ─────────────────────────

            Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 26

    Row {
        anchors.centerIn: parent
        spacing: 14

        // Previous
        Rectangle {
            width: 30
            height: 30
            radius: 15
            color: prevMediaMouse.containsMouse
                   ? Colors.withAlpha(Colors.colSurface, 0.90)
                   : "transparent"

            Text {
                anchors.centerIn: parent
                text: "󰒮"
                color: Colors.colBlue
                font.pixelSize: 18
            }

            MouseArea {
                id: prevMediaMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    MediaService.previous()
            }
        }

        // Play / Pause
Rectangle {
    width: 34
    height: 34
    radius: 17

    color:
        playMediaMouse.containsMouse
        ? Colors.withAlpha(
              Colors.colAccent,
              0.28
          )
        : Colors.withAlpha(
              Colors.colAccent,
              0.18
          )

    border.width: 1
    border.color:
        Colors.withAlpha(
            Colors.colAccent,
            0.58
        )

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset:
            MediaService.playing ? 0 : 1
        anchors.verticalCenterOffset: -1

        text:
            MediaService.playing
            ? ""
            : ""

        color: Colors.colFg
        font.pixelSize: 14
    }

    MouseArea {
        id: playMediaMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked:
            MediaService.playPause()
    	    }
	}

        // Next
        Rectangle {
            width: 30
            height: 30
            radius: 15
            color: nextMediaMouse.containsMouse
                   ? Colors.withAlpha(Colors.colSurface, 0.90)
                   : "transparent"

            Text {
                anchors.centerIn: parent
                text: "󰒭"
                color: Colors.colBlue
                font.pixelSize: 18
            }

            MouseArea {
                id: nextMediaMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    MediaService.next()
                }
              }
   	    }
	 }
      }
   }      		
}
}
}	  
    // ═════════════════════════════════════
    // SYSTEM STATS
    // ═════════════════════════════════════

    Process {
        id: cpuProc

        command: [
            "bash",
            "-c",
            "top -bn1 | grep 'Cpu(s)' | awk '{print int($2+$4)\"%\"}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let value = text.trim()

                if (value !== "")
                    root.cpuProcText = value
            }
        }
    }

    Process {
        id: ramProc

        command: [
            "bash",
            "-c",
            "free | awk '/Mem:/ {printf \"%.0f%%\", $3/$2 * 100}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let value = text.trim()

                if (value !== "")
                    root.ramProcText = value
            }
        }
    }

    Process {
        id: batteryProc

        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let value =
                    parseInt(text.trim())

                if (!isNaN(value)) {
                    root.batteryPercent = value
                    root.batteryText =
                        value + "%"
                }
            }
        }
    }

    Process {
        id: batteryStatusProc

        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT0/status 2>/dev/null"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.batteryStatus =
                    text.trim()
            }
        }
    }

    // ═════════════════════════════════════
    // POWER
    // ═════════════════════════════════════

    Process {
        id: poweroffProc
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: logoutProc

        command: [
            "hyprctl",
            "dispatch",
            "exit"
        ]
    }

    // ═════════════════════════════════════
    // REFRESH
    // ═════════════════════════════════════

    Timer {
        interval: 3000
        repeat: true
        running: true

        onTriggered: {
            if (!cpuProc.running)
                cpuProc.running = true

            if (!ramProc.running)
                ramProc.running = true
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true

        onTriggered: {
            if (!batteryProc.running)
                batteryProc.running = true

            if (!batteryStatusProc.running)
                batteryStatusProc.running = true
        }
    }
}
