import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../"

Rectangle {
    id: trayWidgetRoot
    property var barWindow
    property bool moduleActive: true

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    color: "transparent"

    readonly property real iconSize: barWindow ? barWindow.s(16) : 16
    readonly property real itemSpacing: barWindow ? barWindow.s(10) : 10
    readonly property real leftPadding: barWindow ? barWindow.s(7) : 7
    readonly property real rightPadding: barWindow ? barWindow.s(7) : 7

    property real targetWidth: (moduleActive && trayRepeater.count > 0)
        ? (trayRepeater.count * iconSize + (trayRepeater.count - 1) * itemSpacing + leftPadding + rightPadding)
        : 0
    width: targetWidth
    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    opacity: (moduleActive && targetWidth > 0) ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Row {
        id: trayLayout
        anchors.left: parent.left
        anchors.leftMargin: trayWidgetRoot.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: trayWidgetRoot.itemSpacing

        Repeater {
            id: trayRepeater
            model: trayWidgetRoot.moduleActive ? SystemTray.items : null

            delegate: Image {
                id: trayIcon
                source: modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(trayWidgetRoot.iconSize, trayWidgetRoot.iconSize)
                width: trayWidgetRoot.iconSize
                height: trayWidgetRoot.iconSize
                anchors.verticalCenter: parent.verticalCenter

                QsMenuAnchor {
                    id: menuAnchor
                    menu: modelData.menu ?? null
                    anchor.window: barWindow
                    anchor.rect: Qt.rect(
                        trayIcon.mapToItem(null, 0, trayIcon.height).x,
                        trayIcon.mapToItem(null, 0, trayIcon.height).y,
                        trayIcon.width,
                        1
                    )
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -(barWindow ? barWindow.s(4) : 4)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            if (modelData.menu) menuAnchor.open();
                        } else if (mouse.button === Qt.LeftButton) {
                            if (typeof modelData.activate === "function") modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            if (typeof modelData.secondaryActivate === "function") modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
