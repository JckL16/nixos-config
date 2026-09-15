import QtQuick
import Quickshell
import "../"
import "modules"

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            property int barHeight: Math.round(30 * Scaler.baseScale)
            property real baseOffsetY: 0
            property real barOpacity: 1.0
            property bool distinctPills: false
            property bool startupCascadeFinished: false

            function s(val) {
                return Math.round(Scaler.s(val));
            }

            Timer { interval: 300; running: true; onTriggered: barWindow.startupCascadeFinished = true }

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: barHeight
            exclusiveZone: barHeight + s(6)
            color: "transparent"

            margins {
                top: s(6)
                left: s(5)
                right: s(11)
            }

            WorkspacesWidget { id: workspacesWidget; barWindow: barWindow }

            MediaWidget {
                barWindow: barWindow
                targetX: workspacesWidget.x + workspacesWidget.width + barWindow.s(2)
            }

            ClockWidget {
                barWindow: barWindow
                anchors.horizontalCenter: parent.horizontalCenter
            }

            NotificationWidget {
                id: notificationWidget
                barWindow: barWindow
                targetX: barWindow.width - width
            }
            TrayWidget {
                id: trayWidget
                barWindow: barWindow
                targetX: notificationWidget.x - width - barWindow.s(2)
            }
            BatWidget {
                id: batWidget
                barWindow: barWindow
                targetX: trayWidget.x - width - barWindow.s(2)
            }
            SysMonWidget {
                id: sysMonWidget
                barWindow: barWindow
                targetX: batWidget.x - width - barWindow.s(2)
            }
            BtWidget {
                id: btWidget
                barWindow: barWindow
                targetX: sysMonWidget.x - width - barWindow.s(2)
            }
            NetworkWidget {
                id: networkWidget
                barWindow: barWindow
                targetX: btWidget.x - width - barWindow.s(2)
            }
            VolWidget {
                barWindow: barWindow
                targetX: networkWidget.x - width - barWindow.s(2)
            }
        }
    }
}
