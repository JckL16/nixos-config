import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../"

Rectangle {
    id: resizeModeWidgetRoot

    property var barWindow
    property bool active: false

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap") {
                resizeModeWidgetRoot.active = (event.data === "resize");
            }
        }
    }

    property real targetX: 0
    x: targetX

    radius: ThemeBackend.borderRadius
    border.width: 0
    color: ThemeBackend.peach
    height: barWindow ? barWindow.barHeight - 6 : 24
    y: barWindow ? barWindow.baseOffsetY + (barWindow.barHeight - height) / 2 : 0

    property real targetWidth: active ? (contentRow.implicitWidth + barWindow.s(14)) : 0
    width: targetWidth
    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

    opacity: active ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: barWindow ? barWindow.s(5) : 5

        Text {
            text: "⤢"
            font.family: ThemeBackend.fontFamily
            font.pixelSize: barWindow ? barWindow.s(13) : 13
            font.bold: true
            color: ThemeBackend.base
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "RESIZE"
            font.family: ThemeBackend.fontFamily
            font.pixelSize: barWindow ? barWindow.s(11) : 11
            font.bold: true
            color: ThemeBackend.base
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
