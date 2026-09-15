import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import "../../reusables"
import "../../"

Rectangle {
    id: wifiWidgetRoot
    property var barWindow
    property bool moduleActive: true

    property string ethStatus: "Ethernet"
    property string wifiIcon: "󰤮"
    property string wifiSsid: ""
    property bool isWifiOn: Networking.wifiEnabled
    property bool showEthernet: ethStatus === "Connected"

    property var ethDevice: null
    property var wifiDevice: null

    Component.onCompleted: {
        findDevices();
        updateNetworkData();
    }

    function isEthDevice(dev) { return !!dev && dev.type === DeviceType.Wired; }
    function isWifiDevice(dev) { return !!dev && dev.type === DeviceType.Wifi; }

    function findDevices() {
        if (!Networking || !Networking.devices) return;
        let devs = Networking.devices.values || Networking.devices;
        let count = devs.length !== undefined ? devs.length : (devs.count !== undefined ? devs.count : 0);

        let bestEth = null;
        let bestWifi = null;
        for (let i = 0; i < count; i++) {
            let d = devs[i] !== undefined ? devs[i] : (devs.get ? devs.get(i) : null);
            if (!d) continue;
            if (isEthDevice(d)) {
                if (!bestEth || d.connected) bestEth = d;
            } else if (isWifiDevice(d)) {
                if (!bestWifi || d.connected) bestWifi = d;
            }
        }
        wifiWidgetRoot.ethDevice = bestEth;
        wifiWidgetRoot.wifiDevice = bestWifi;
    }

    function getWifiNetworksList() {
        if (!wifiDevice || !wifiDevice.networks) return [];
        let nets = wifiDevice.networks.values || wifiDevice.networks;
        let list = [];
        let count = nets.length !== undefined ? nets.length : (nets.count !== undefined ? nets.count : 0);
        for (let i = 0; i < count; i++) {
            let n = nets[i] !== undefined ? nets[i] : (nets.get ? nets.get(i) : null);
            if (n) list.push(n);
        }
        return list;
    }

    function updateNetworkData() {
        findDevices();
        let isWifiEnabled = Networking.wifiEnabled;

        if (ethDevice) {
            switch (ethDevice.state) {
                case ConnectionState.Connected: ethStatus = "Connected"; break;
                case ConnectionState.Connecting: ethStatus = "Connecting…"; break;
                case ConnectionState.Disconnecting: ethStatus = "Disconnecting…"; break;
                default: ethStatus = "Disconnected"; break;
            }
        } else {
            ethStatus = "Ethernet";
        }

        if (!isWifiEnabled) {
            wifiSsid = "";
            wifiIcon = "󰤮";
            return;
        }

        let connectedNet = null;
        let netList = getWifiNetworksList();
        for (let i = 0; i < netList.length; i++) {
            if (netList[i] && netList[i].connected) { connectedNet = netList[i]; break; }
        }

        if (connectedNet) {
            wifiSsid = connectedNet.name || connectedNet.ssid || "";
            let sig = connectedNet.signalStrength !== undefined ? Math.round(connectedNet.signalStrength * (connectedNet.signalStrength <= 1 ? 100 : 1)) : 100;
            if (sig >= 80) wifiIcon = "󰤨";
            else if (sig >= 60) wifiIcon = "󰤥";
            else if (sig >= 40) wifiIcon = "󰤢";
            else if (sig >= 20) wifiIcon = "󰤟";
            else wifiIcon = "󰤯";
        } else {
            wifiSsid = "";
            wifiIcon = "󰤯";
        }
    }

    Item {
        visible: false
        Connections {
            target: Networking
            ignoreUnknownSignals: true
            function onWifiEnabledChanged() { wifiWidgetRoot.updateNetworkData(); }
            function onDevicesChanged() { wifiWidgetRoot.findDevices(); wifiWidgetRoot.updateNetworkData(); }
        }
        Repeater {
            model: Networking.devices
            Item {
                property var device: modelData
                Component.onCompleted: wifiWidgetRoot.updateNetworkData()
                Connections {
                    target: device || null
                    ignoreUnknownSignals: true
                    function onStateChanged() { wifiWidgetRoot.updateNetworkData(); }
                    function onConnectedChanged() { wifiWidgetRoot.updateNetworkData(); }
                }
            }
        }
        Repeater {
            model: wifiWidgetRoot.wifiDevice ? wifiWidgetRoot.wifiDevice.networks : null
            Item {
                property var network: modelData
                Component.onCompleted: wifiWidgetRoot.updateNetworkData()
                Connections {
                    target: network || null
                    ignoreUnknownSignals: true
                    function onSignalStrengthChanged() { wifiWidgetRoot.updateNetworkData(); }
                    function onConnectedChanged() { wifiWidgetRoot.updateNetworkData(); }
                }
            }
        }
    }

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    radius: ThemeBackend.borderRadius
    color: "transparent"
    clip: true

    property real targetWidth: (moduleActive && sysLayout.implicitWidth > 0) ? (sysLayout.implicitWidth + barWindow.s(10)) : 0
    width: targetWidth

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Row {
        id: sysLayout
        anchors.centerIn: parent

        ClickButton {
            id: wifiPill
            property bool isActive: showEthernet ? (ethStatus === "Connected") : isWifiOn

            height: barWindow ? barWindow.s(30) : 30
            maxWidth: barWindow ? barWindow.s(160) : 160
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(2) : 2))
            horizontalPadding: barWindow ? barWindow.s(4) : 4
            buttonIcon: showEthernet ? "󰈀" : wifiIcon
            iconFontSize: barWindow ? barWindow.s(15) : 15
            buttonText: showEthernet ? ethStatus : ((isWifiOn ? (wifiSsid !== "" ? wifiSsid : "On") : "Off"))
            textFontSize: barWindow ? barWindow.s(12) : 12
            accentColor: "transparent"
            textColor: ThemeBackend.text

            width: implicitWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            onClicked: netPopup.visible = !netPopup.visible
        }
    }

    PopupWindow {
        id: netPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(240) : 240
        implicitHeight: popupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)

        anchor.item: wifiPill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.All

        grabFocus: true

        onVisibleChanged: {
            if (wifiWidgetRoot.wifiDevice) wifiWidgetRoot.wifiDevice.scannerEnabled = visible;
        }

        Rectangle {
            anchors.fill: parent
            radius: ThemeBackend.borderRadius
            color: ThemeBackend.mantle
            border.width: 1
            border.color: ThemeBackend.surface1

            Column {
                id: popupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(10) : 10

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "󰈀"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(14) : 14
                        color: wifiWidgetRoot.ethDevice && wifiWidgetRoot.ethStatus === "Connected" ? ThemeBackend.green : ThemeBackend.subtext0
                    }
                    Column {
                        Layout.fillWidth: true
                        Text {
                            text: "Ethernet"
                            font.family: ThemeBackend.fontFamily
                            font.weight: Font.Bold
                            font.pixelSize: barWindow ? barWindow.s(12) : 12
                            color: ThemeBackend.text
                        }
                        Text {
                            text: wifiWidgetRoot.ethDevice
                                ? (wifiWidgetRoot.ethStatus + (wifiWidgetRoot.ethDevice.name ? " · " + wifiWidgetRoot.ethDevice.name : ""))
                                : "No device"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(10) : 10
                            color: ThemeBackend.subtext0
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Wi-Fi"
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: barWindow ? barWindow.s(12) : 12
                        color: ThemeBackend.text
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: barWindow ? barWindow.s(36) : 36
                        height: barWindow ? barWindow.s(18) : 18
                        radius: height / 2
                        color: Networking.wifiEnabled ? ThemeBackend.mauve : ThemeBackend.surface0
                        Rectangle {
                            width: parent.height - 4
                            height: parent.height - 4
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            x: Networking.wifiEnabled ? (parent.width - width - 2) : 2
                            color: ThemeBackend.base
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }
                }

                Text {
                    text: "Networks"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(10) : 10
                    color: ThemeBackend.subtext0
                }

                Repeater {
                    model: wifiWidgetRoot.wifiDevice ? wifiWidgetRoot.getWifiNetworksList() : []

                    delegate: Column {
                        id: netRow
                        required property var modelData
                        property bool needsPassword: !modelData.known && modelData.security !== WifiSecurityType.Open
                        property bool expanded: false
                        width: popupContent.width
                        spacing: 4

                        Rectangle {
                            width: parent.width
                            height: barWindow ? barWindow.s(28) : 28
                            radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                            color: netRow.modelData.connected ? ThemeBackend.surface1 : (netRow.expanded ? ThemeBackend.surface0 : "transparent")

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: {
                                        let s = netRow.modelData.signalStrength !== undefined ? (netRow.modelData.signalStrength <= 1 ? netRow.modelData.signalStrength * 100 : netRow.modelData.signalStrength) : 100;
                                        return s >= 66 ? "󰤨" : (s >= 33 ? "󰤢" : "󰤟");
                                    }
                                    font.family: ThemeBackend.fontFamily
                                    font.pixelSize: barWindow ? barWindow.s(12) : 12
                                    color: netRow.modelData.connected ? ThemeBackend.text : ThemeBackend.subtext0
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: netRow.modelData.name || "(hidden)"
                                    elide: Text.ElideRight
                                    font.family: ThemeBackend.fontFamily
                                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                                    color: netRow.modelData.connected ? ThemeBackend.text : ThemeBackend.subtext0
                                }
                                Text {
                                    visible: netRow.needsPassword && !netRow.modelData.connected
                                    text: "󰌾"
                                    font.family: ThemeBackend.fontFamily
                                    font.pixelSize: barWindow ? barWindow.s(10) : 10
                                    color: ThemeBackend.subtext0
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (netRow.modelData.connected) {
                                        netRow.modelData.disconnect();
                                    } else if (netRow.needsPassword) {
                                        netRow.expanded = !netRow.expanded;
                                    } else {
                                        netRow.modelData.connect();
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: netRow.expanded
                            width: parent.width
                            spacing: 4

                            TextField {
                                id: pwField
                                Layout.fillWidth: true
                                echoMode: TextInput.Password
                                placeholderText: "Password"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: ThemeBackend.text
                                background: Rectangle {
                                    radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                                    color: ThemeBackend.surface0
                                    border.width: 1
                                    border.color: ThemeBackend.surface2
                                }
                                onAccepted: {
                                    netRow.modelData.connectWithPsk(text);
                                    netRow.expanded = false;
                                    text = "";
                                }
                            }
                            Text {
                                text: "Connect"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: ThemeBackend.mauve
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        netRow.modelData.connectWithPsk(pwField.text);
                                        netRow.expanded = false;
                                        pwField.text = "";
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Rectangle {
                    width: parent.width
                    height: barWindow ? barWindow.s(26) : 26
                    radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                    color: "transparent"
                    border.width: 1
                    border.color: ThemeBackend.surface1

                    Text {
                        anchors.centerIn: parent
                        text: "Connection Editor"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let nc = "root=" + ThemeBackend.text + "," + ThemeBackend.base
                                + " window=" + ThemeBackend.text + "," + ThemeBackend.base
                                + " border=" + ThemeBackend.mauve + "," + ThemeBackend.base
                                + " title=" + ThemeBackend.mauve + "," + ThemeBackend.base
                                + " label=" + ThemeBackend.subtext0 + "," + ThemeBackend.base
                                + " button=" + ThemeBackend.base + "," + ThemeBackend.mauve
                                + " actbutton=" + ThemeBackend.base + "," + ThemeBackend.blue
                                + " listbox=" + ThemeBackend.text + "," + ThemeBackend.base
                                + " actlistbox=" + ThemeBackend.base + "," + ThemeBackend.mauve
                                + " textbox=" + ThemeBackend.text + "," + ThemeBackend.base
                                + " acttextbox=" + ThemeBackend.base + "," + ThemeBackend.mauve
                                + " entry=" + ThemeBackend.text + "," + ThemeBackend.mantle
                                + " checkbox=" + ThemeBackend.text + "," + ThemeBackend.base
                                + " actcheckbox=" + ThemeBackend.base + "," + ThemeBackend.mauve
                                + " helpline=" + ThemeBackend.subtext0 + "," + ThemeBackend.base
                                + " roottext=" + ThemeBackend.subtext0 + "," + ThemeBackend.base;
                            Quickshell.execDetached(["alacritty", "--class", "quickshell-nmtui", "-e", "sh", "-c", "NEWT_COLORS='" + nc + "' exec nmtui"]);
                            netPopup.visible = false;
                        }
                    }
                }
            }
        }
    }
}
