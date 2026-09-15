import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../../"

Rectangle {
    id: batWidgetRoot
    property var barWindow
    property bool moduleActive: true

    property bool isDesktop: UPower.displayDevice.ready ? !UPower.displayDevice.isLaptopBattery : true
    readonly property int batCap: UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property string batPercent: batCap + "%"
    readonly property bool isCharging: UPower.displayDevice.ready && (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
    readonly property string batIcon: isDesktop ? "󰐥" : (isCharging ? "󰂄" : (batCap > 20 ? "󰁹" : "󰂃"))

    property real uptimeSeconds: 0

    function fmtDuration(totalSeconds) {
        const s = Math.max(0, Math.round(totalSeconds));
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        if (h > 0) return h + "h " + m + "m";
        return m + "m";
    }

    Process {
        id: uptimeProc
        running: false
        command: ["cat", "/proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const first = text.trim().split(/\s+/)[0];
                const v = parseFloat(first);
                if (!isNaN(v)) batWidgetRoot.uptimeSeconds = v;
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: batWidgetRoot.moduleActive
        triggeredOnStart: true
        onTriggered: { uptimeProc.running = false; uptimeProc.running = true; }
    }

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    color: "transparent"

    property real targetWidth: (moduleActive && contentRow.implicitWidth > 0) ? (contentRow.implicitWidth + barWindow.s(14)) : 0
    width: targetWidth

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        id: batShape
        anchors.fill: parent
        radius: ThemeBackend.borderRadius
        color: "transparent"

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: batWidgetRoot.isDesktop ? 0 : (barWindow ? barWindow.s(5) : 5)

            Text {
                text: batWidgetRoot.batIcon
                font.family: ThemeBackend.fontFamily
                font.pixelSize: batWidgetRoot.isDesktop ? (barWindow ? barWindow.s(16) : 16) : (barWindow ? barWindow.s(13.5) : 13.5)
                color: ThemeBackend.subtext0
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: !batWidgetRoot.isDesktop
                text: batWidgetRoot.batPercent
                font.family: ThemeBackend.fontFamily
                font.pixelSize: barWindow ? barWindow.s(12.6) : 12.6
                font.bold: true
                color: ThemeBackend.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!batPopup.visible) { uptimeProc.running = false; uptimeProc.running = true; }
                batPopup.visible = !batPopup.visible;
            }
        }
    }

    PopupWindow {
        id: batPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(190) : 190
        implicitHeight: batPopupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)
        anchor.item: batShape
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.All
        grabFocus: true

        Rectangle {
            anchors.fill: parent
            radius: ThemeBackend.borderRadius
            color: ThemeBackend.mantle
            border.width: 1
            border.color: ThemeBackend.surface1

            Column {
                id: batPopupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(6) : 6

                Text {
                    text: batWidgetRoot.isDesktop ? "System" : "Battery"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(12) : 12
                    color: ThemeBackend.text
                }
                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Text {
                    visible: !batWidgetRoot.isDesktop
                    text: "Status: " + (UPower.displayDevice.ready ? UPowerDeviceState.toString(UPower.displayDevice.state) : "Unknown")
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: !batWidgetRoot.isDesktop
                    text: "Charge: " + batWidgetRoot.batPercent
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: !batWidgetRoot.isDesktop && UPower.displayDevice.ready && UPower.displayDevice.state === UPowerDeviceState.Discharging && UPower.displayDevice.timeToEmpty > 0
                    text: "Time remaining: " + batWidgetRoot.fmtDuration(UPower.displayDevice.timeToEmpty)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: !batWidgetRoot.isDesktop && UPower.displayDevice.ready && UPower.displayDevice.state === UPowerDeviceState.Charging && UPower.displayDevice.timeToFull > 0
                    text: "Time to full: " + batWidgetRoot.fmtDuration(UPower.displayDevice.timeToFull)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: !batWidgetRoot.isDesktop && UPower.displayDevice.ready && UPower.displayDevice.healthSupported
                    text: "Health: " + Math.round(UPower.displayDevice.healthPercentage) + "%"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: !batWidgetRoot.isDesktop && UPower.displayDevice.ready && UPower.displayDevice.model !== ""
                    text: "Model: " + UPower.displayDevice.model
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                    elide: Text.ElideRight
                    width: parent.width
                }

                Rectangle { visible: !batWidgetRoot.isDesktop; width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Text {
                    text: "Uptime: " + batWidgetRoot.fmtDuration(batWidgetRoot.uptimeSeconds)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
            }
        }
    }
}
