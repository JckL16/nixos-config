import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../"

Rectangle {
    id: sysMonRoot
    property var barWindow
    property bool moduleActive: true

    property real cpuPercent: 0
    property real ramPercent: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property real ramAvailGb: 0
    property real swapUsedGb: 0
    property real swapTotalGb: 0
    property string loadAvg: ""
    property int cpuCores: 0

    property real prevIdle: -1
    property real prevTotal: -1

    readonly property real kbToGb: 1.0 / 1048576.0

    Process {
        id: statProc
        running: false
        command: ["cat", "/proc/stat", "/proc/meminfo", "/proc/loadavg", "/proc/cpuinfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.split("\n");
                let cpuParts = lines[0].trim().split(/\s+/).slice(1).map(Number);
                if (cpuParts.length >= 4) {
                    let idle = cpuParts[3] + (cpuParts[4] || 0);
                    let total = cpuParts.reduce((a, b) => a + b, 0);
                    if (sysMonRoot.prevTotal >= 0) {
                        let totalDiff = total - sysMonRoot.prevTotal;
                        let idleDiff = idle - sysMonRoot.prevIdle;
                        sysMonRoot.cpuPercent = totalDiff > 0 ? Math.max(0, Math.min(100, 100 * (1 - idleDiff / totalDiff))) : sysMonRoot.cpuPercent;
                    }
                    sysMonRoot.prevIdle = idle;
                    sysMonRoot.prevTotal = total;
                }

                let memTotal = 0, memAvail = 0, swapTotal = 0, swapFree = 0;
                let loadLine = "", cores = 0;
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i];
                    if (line.startsWith("MemTotal:")) memTotal = parseInt(line.split(/\s+/)[1]);
                    else if (line.startsWith("MemAvailable:")) memAvail = parseInt(line.split(/\s+/)[1]);
                    else if (line.startsWith("SwapTotal:")) swapTotal = parseInt(line.split(/\s+/)[1]);
                    else if (line.startsWith("SwapFree:")) swapFree = parseInt(line.split(/\s+/)[1]);
                    else if (line.indexOf(" ") !== -1 && line.split(" ").length >= 3 && /^[0-9.]+ [0-9.]+ [0-9.]+/.test(line)) loadLine = line;
                    else if (line.startsWith("processor")) cores++;
                }
                if (memTotal > 0) {
                    sysMonRoot.ramPercent = Math.max(0, Math.min(100, 100 * (1 - memAvail / memTotal)));
                    sysMonRoot.ramTotalGb = memTotal * sysMonRoot.kbToGb;
                    sysMonRoot.ramAvailGb = memAvail * sysMonRoot.kbToGb;
                    sysMonRoot.ramUsedGb = (memTotal - memAvail) * sysMonRoot.kbToGb;
                }
                sysMonRoot.swapTotalGb = swapTotal * sysMonRoot.kbToGb;
                sysMonRoot.swapUsedGb = (swapTotal - swapFree) * sysMonRoot.kbToGb;
                if (loadLine) {
                    let p = loadLine.trim().split(/\s+/);
                    sysMonRoot.loadAvg = p[0] + "  " + p[1] + "  " + p[2];
                }
                if (cores > 0) sysMonRoot.cpuCores = cores;
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: sysMonRoot.moduleActive
        triggeredOnStart: true
        onTriggered: { statProc.running = false; statProc.running = true; }
    }

    function fmtGb(v) { return v.toFixed(1) + "G"; }

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    color: "transparent"

    property real targetWidth: (moduleActive && sysLayout.implicitWidth > 0) ? sysLayout.implicitWidth : 0
    width: targetWidth

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Row {
        id: sysLayout
        anchors.centerIn: parent
        spacing: barWindow ? -barWindow.s(2) : -2

        Rectangle {
            id: cpuPill
            width: cpuRow.implicitWidth + (barWindow ? barWindow.s(8) : 8)
            height: barWindow ? barWindow.s(30) : 30
            radius: ThemeBackend.borderRadius
            color: "transparent"

            RowLayout {
                id: cpuRow
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: ""
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(13) : 13
                    color: ThemeBackend.subtext0
                }
                Text {
                    text: Math.round(sysMonRoot.cpuPercent) + "%"
                    Layout.preferredWidth: barWindow ? barWindow.s(26) : 26
                    horizontalAlignment: Text.AlignLeft
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    font.bold: true
                    color: ThemeBackend.text
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: cpuPopup.visible = !cpuPopup.visible
            }
        }

        Rectangle {
            id: ramPill
            width: ramRow.implicitWidth + (barWindow ? barWindow.s(8) : 8)
            height: barWindow ? barWindow.s(30) : 30
            radius: ThemeBackend.borderRadius
            color: "transparent"

            RowLayout {
                id: ramRow
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: ""
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(13) : 13
                    color: ThemeBackend.subtext0
                }
                Text {
                    text: Math.round(sysMonRoot.ramPercent) + "%"
                    Layout.preferredWidth: barWindow ? barWindow.s(26) : 26
                    horizontalAlignment: Text.AlignLeft
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    font.bold: true
                    color: ThemeBackend.text
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ramPopup.visible = !ramPopup.visible
            }
        }
    }

    PopupWindow {
        id: cpuPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(180) : 180
        implicitHeight: cpuPopupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)
        anchor.item: cpuPill
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
                id: cpuPopupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(6) : 6

                Text {
                    text: "CPU"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(12) : 12
                    color: ThemeBackend.text
                }
                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }
                Text {
                    text: "Usage: " + Math.round(sysMonRoot.cpuPercent) + "%"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: sysMonRoot.cpuCores > 0
                    text: "Cores: " + sysMonRoot.cpuCores
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: sysMonRoot.loadAvg !== ""
                    text: "Load (1/5/15m): " + sysMonRoot.loadAvg
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
            }
        }
    }

    PopupWindow {
        id: ramPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(180) : 180
        implicitHeight: ramPopupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)
        anchor.item: ramPill
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
                id: ramPopupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(6) : 6

                Text {
                    text: "Memory"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(12) : 12
                    color: ThemeBackend.text
                }
                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }
                Text {
                    text: "Used: " + sysMonRoot.fmtGb(sysMonRoot.ramUsedGb) + " / " + sysMonRoot.fmtGb(sysMonRoot.ramTotalGb) + " (" + Math.round(sysMonRoot.ramPercent) + "%)"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    text: "Available: " + sysMonRoot.fmtGb(sysMonRoot.ramAvailGb)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
                Text {
                    visible: sysMonRoot.swapTotalGb > 0
                    text: "Swap: " + sysMonRoot.fmtGb(sysMonRoot.swapUsedGb) + " / " + sysMonRoot.fmtGb(sysMonRoot.swapTotalGb)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.subtext0
                }
            }
        }
    }
}
