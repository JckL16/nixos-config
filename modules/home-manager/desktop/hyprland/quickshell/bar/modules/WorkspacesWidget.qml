import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import "../../"

Rectangle {
    id: workspacesWidgetRoot

    property var barWindow
    property bool isSolid: false
    property bool distinctPills: barWindow ? (barWindow.distinctPills !== undefined ? barWindow.distinctPills : false) : false
    property bool moduleActive: true
    property bool isGrouped: false
    property bool isCompact: isGrouped || (isSolid && distinctPills)

    property int workspaceCount: (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar && Config.rawSettings.bar.workspaceCount !== undefined) ? Math.max(2, Math.min(10, Config.rawSettings.bar.workspaceCount)) : 8

    function wsForId(id) {
        return Hyprland.workspaces.values.find(w => w.id === id) ?? null;
    }

    property int activeIndex: {
        const fw = Hyprland.focusedWorkspace;
        if (!fw) return -1;
        let idx = fw.id - 1;
        return (idx >= 0 && idx < workspaceCount) ? idx : -1;
    }

    property real targetX: 0
    x: targetX
    Behavior on x {
        enabled: barWindow && barWindow.startupCascadeFinished
        NumberAnimation { duration: 600; easing.type: Easing.OutQuint }
    }

    radius: ThemeBackend.borderRadius
    border.width: 0
    color: "transparent"
    height: barWindow ? (isGrouped ? barWindow.barHeight - 8 : ((isSolid && distinctPills) ? barWindow.barHeight - 6 : barWindow.barHeight)) : (isGrouped ? 22 : ((isSolid && distinctPills) ? 24 : 30))
    y: barWindow ? barWindow.baseOffsetY + (barWindow.barHeight - height) / 2 : 0
    clip: true

    property real targetWidth: (moduleActive && workspaceCount > 0) ? wsLayout.implicitWidth + barWindow.s(8) : 0
    width: targetWidth
    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

    opacity: (moduleActive && workspaceCount > 0) ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    property real wheelAccumulator: 0
    Timer {
        id: wsWheelTimer
        interval: 200
        onTriggered: workspacesWidgetRoot.wheelAccumulator = 0
    }

    MouseArea {
        id: wsScrollArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            wsWheelTimer.restart();
            workspacesWidgetRoot.wheelAccumulator += wheel.angleDelta.y;
            const threshold = 120;
            if (Math.abs(workspacesWidgetRoot.wheelAccumulator) >= threshold) {
                let steps = Math.trunc(workspacesWidgetRoot.wheelAccumulator / threshold);
                workspacesWidgetRoot.wheelAccumulator = workspacesWidgetRoot.wheelAccumulator % threshold;

                if (workspacesWidgetRoot.workspaceCount > 1) {
                    let cur = workspacesWidgetRoot.activeIndex;
                    let nextIndex = 0;
                    if (cur < 0) {
                        nextIndex = steps > 0 ? (workspacesWidgetRoot.workspaceCount - 1) : 0;
                    } else {
                        if (steps > 0) {
                            nextIndex = (cur - 1 + workspacesWidgetRoot.workspaceCount) % workspacesWidgetRoot.workspaceCount;
                        } else if (steps < 0) {
                            nextIndex = (cur + 1) % workspacesWidgetRoot.workspaceCount;
                        }
                    }
                    if (nextIndex !== workspacesWidgetRoot.activeIndex) {
                        Hyprland.dispatch("workspace " + (nextIndex + 1));
                    }
                }
            }
        }
    }

    Row {
        id: wsLayout
        z: 2
        anchors.centerIn: parent
        spacing: barWindow.s(workspacesWidgetRoot.isCompact ? 7 : 8)

        Repeater {
            model: workspacesWidgetRoot.workspaceCount

            delegate: Item {
                id: wsPill

                required property int index
                property int wsId: index + 1
                property var ws: workspacesWidgetRoot.wsForId(wsId)
                property bool isOccupied: ws !== null && ws.toplevels && ws.toplevels.values && ws.toplevels.values.length > 0
                property bool isActive: index === workspacesWidgetRoot.activeIndex
                property bool initAnimTrigger: false

                width: isActive ? barWindow.s(workspacesWidgetRoot.isCompact ? 42 : 46) : barWindow.s(workspacesWidgetRoot.isCompact ? 22 : 24)
                height: barWindow.s(workspacesWidgetRoot.isCompact ? 22 : 24)
                anchors.verticalCenter: parent.verticalCenter

                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

                Rectangle {
                    id: wsVisualShape
                    anchors.fill: parent
                    radius: barWindow.s(workspacesWidgetRoot.isCompact ? 8 : 10)
                    color: wsPill.isActive ? ThemeBackend.overlay1 : (wsPill.isOccupied ? ThemeBackend.surface2 : (workspacesWidgetRoot.isCompact ? ThemeBackend.surface1 : ThemeBackend.surface0))
                    border.width: 0

                    Behavior on color { ColorAnimation { duration: 250 } }

                    scale: wsPillMouse.pressed ? 0.88 : (wsPillMouse.containsMouse ? 1.08 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }

                    Text {
                        anchors.centerIn: parent
                        text: wsPill.wsId
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow.s(workspacesWidgetRoot.isCompact ? 11 : 12)
                        font.weight: Font.Bold
                        color: wsPill.isActive ? ThemeBackend.base : ThemeBackend.text
                    }
                }

                opacity: initAnimTrigger ? 1.0 : 0.0
                transform: Translate {
                    y: wsPill.initAnimTrigger ? 0 : barWindow.s(15)
                    Behavior on y { NumberAnimation { duration: 650; easing.type: Easing.OutQuint } }
                }

                Component.onCompleted: {
                    if (!barWindow.startupCascadeFinished) {
                        animTimer.interval = index * 50 + 100;
                        if (workspacesWidgetRoot.moduleActive) animTimer.start();
                    } else {
                        initAnimTrigger = true;
                    }
                }

                Timer {
                    id: animTimer
                    running: false; repeat: false
                    onTriggered: wsPill.initAnimTrigger = true
                }

                Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: wsPillMouse
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
                }
            }
        }
    }
}
