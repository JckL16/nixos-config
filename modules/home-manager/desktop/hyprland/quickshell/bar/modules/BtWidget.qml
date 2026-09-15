import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../../reusables"
import "../../"

Rectangle {
    id: btWidgetRoot
    property var barWindow
    property bool moduleActive: true

    property string btIcon: "󰂲"
    property string btDevice: "Off"
    property bool isBtOn: false

    Component.onCompleted: updateBtData();

    readonly property var macNamePattern: /^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/

    function getBtDevicesList() {
        let adapter = Bluetooth.defaultAdapter;
        if (!adapter || !adapter.devices) return [];
        let devs = adapter.devices.values || adapter.devices;
        let list = [];
        let count = devs.length !== undefined ? devs.length : (devs.count !== undefined ? devs.count : 0);
        for (let i = 0; i < count; i++) {
            let d = devs[i] !== undefined ? devs[i] : (devs.get ? devs.get(i) : null);
            if (!d) continue;
            let name = d.name || d.deviceName || "";
            let looksLikeMac = macNamePattern.test(name.trim());
            if (d.bonded || (name !== "" && !looksLikeMac)) list.push(d);
        }
        return list;
    }

    function updateBtData() {
        let adapter = Bluetooth.defaultAdapter;
        let enabled = adapter ? adapter.enabled : false;
        btWidgetRoot.isBtOn = enabled;

        if (!enabled) {
            btIcon = "󰂲";
            btDevice = "Off";
            return;
        }

        let connectedDev = null;
        let devList = getBtDevicesList();
        for (let i = 0; i < devList.length; i++) {
            if (devList[i] && devList[i].connected) { connectedDev = devList[i]; break; }
        }

        if (connectedDev) {
            let name = connectedDev.name || connectedDev.deviceName || connectedDev.address || "";
            let typeLower = (connectedDev.icon || "").toLowerCase();
            let nameLower = name.toLowerCase();
            let icon = "󰂯";
            if (typeLower.indexOf("headset") !== -1 || nameLower.indexOf("buds") !== -1 || nameLower.indexOf("pods") !== -1) icon = "󰋋";
            else if (typeLower.indexOf("mouse") !== -1 || nameLower.indexOf("mouse") !== -1) icon = "󰍽";
            else if (typeLower.indexOf("keyboard") !== -1 || nameLower.indexOf("keyboard") !== -1) icon = "󰌌";
            btIcon = icon;
            btDevice = name;
        } else {
            btIcon = "󰂯";
            btDevice = "On";
        }
    }

    Item {
        visible: false
        Connections {
            target: Bluetooth
            ignoreUnknownSignals: true
            function onDefaultAdapterChanged() { btWidgetRoot.updateBtData(); }
        }
        Connections {
            target: Bluetooth.defaultAdapter || null
            ignoreUnknownSignals: true
            function onEnabledChanged() { btWidgetRoot.updateBtData(); }
            function onDevicesChanged() { btWidgetRoot.updateBtData(); }
        }
        Repeater {
            model: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices : null
            Item {
                property var device: modelData
                Component.onCompleted: btWidgetRoot.updateBtData()
                Connections {
                    target: device || null
                    ignoreUnknownSignals: true
                    function onConnectedChanged() { btWidgetRoot.updateBtData(); }
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
            id: btPill
            height: barWindow ? barWindow.s(30) : 30
            maxWidth: barWindow ? barWindow.s(160) : 160
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(2) : 2))
            horizontalPadding: barWindow ? barWindow.s(4) : 4
            buttonIcon: btIcon
            iconFontSize: barWindow ? barWindow.s(15) : 15
            buttonText: btDevice
            textFontSize: barWindow ? barWindow.s(12) : 12
            accentColor: "transparent"
            textColor: ThemeBackend.text

            width: implicitWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            onClicked: btPopup.visible = !btPopup.visible
        }
    }

    PopupWindow {
        id: btPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(240) : 240
        implicitHeight: popupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)

        anchor.item: btPill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.All

        grabFocus: true

        onVisibleChanged: {
            if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.discovering = visible;
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
                        text: "Bluetooth"
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
                        color: btWidgetRoot.isBtOn ? ThemeBackend.mauve : ThemeBackend.surface0
                        Rectangle {
                            width: parent.height - 4
                            height: parent.height - 4
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            x: btWidgetRoot.isBtOn ? (parent.width - width - 2) : 2
                            color: ThemeBackend.base
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Bluetooth.defaultAdapter) {
                                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Text {
                    text: "Devices"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(10) : 10
                    color: ThemeBackend.subtext0
                }

                Repeater {
                    model: btWidgetRoot.getBtDevicesList()

                    delegate: Column {
                        id: btRowWrap
                        required property var modelData
                        property bool isTransitioning: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
                        width: popupContent.width
                        spacing: barWindow ? barWindow.s(4) : 4

                        Rectangle {
                        width: parent.width
                        height: barWindow ? barWindow.s(28) : 28
                        radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                        color: btRowWrap.isTransitioning ? ThemeBackend.mauve : (btRowWrap.modelData.connected ? ThemeBackend.surface1 : "transparent")
                        opacity: btRowWrap.isTransitioning ? (pulseAnim.running ? pulseAnim.value : 1.0) : 1.0

                        SequentialAnimation {
                            id: pulseAnim
                            property real value: 1.0
                            running: btRowWrap.isTransitioning
                            loops: Animation.Infinite
                            NumberAnimation { target: pulseAnim; property: "value"; from: 1.0; to: 0.5; duration: 500 }
                            NumberAnimation { target: pulseAnim; property: "value"; from: 0.5; to: 1.0; duration: 500 }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                text: btRowWrap.modelData.name || btRowWrap.modelData.deviceName || "Unknown device"
                                elide: Text.ElideRight
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: btRowWrap.isTransitioning ? ThemeBackend.base : (btRowWrap.modelData.connected ? ThemeBackend.text : ThemeBackend.subtext0)
                            }
                            Text {
                                visible: text !== ""
                                text: {
                                    switch (btRowWrap.modelData.state) {
                                        case BluetoothDeviceState.Connecting: return "Connecting…";
                                        case BluetoothDeviceState.Disconnecting: return "Disconnecting…";
                                        case BluetoothDeviceState.Connected: return "Connected";
                                        default: return "";
                                    }
                                }
                                font.family: ThemeBackend.fontFamily
                                font.weight: Font.Bold
                                font.pixelSize: barWindow ? barWindow.s(10) : 10
                                color: btRowWrap.isTransitioning ? ThemeBackend.base : ThemeBackend.green
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: btRowWrap.modelData.state !== BluetoothDeviceState.Connecting && btRowWrap.modelData.state !== BluetoothDeviceState.Disconnecting
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btRowWrap.modelData.connected = !btRowWrap.modelData.connected
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
                        text: "Bluetooth Manager"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["alacritty", "--class", "quickshell-bluetui", "-e", "bluetui"]);
                            btPopup.visible = false;
                        }
                    }
                }
            }
        }
    }
}
