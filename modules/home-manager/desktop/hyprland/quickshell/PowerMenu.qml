import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
    property bool menuVisible: false

    component PowerMenuButton: Rectangle {
        id: btn
        property string icon: ""
        property string label: ""
        property color accentColor: ThemeBackend.mauve
        signal activated()

        width: Scaler.s(110)
        height: Scaler.s(110)
        radius: Scaler.s(16)
        color: mouse.containsMouse ? Qt.lighter(ThemeBackend.surface0, 1.15) : ThemeBackend.surface0
        border.width: 1
        border.color: mouse.containsMouse ? btn.accentColor : ThemeBackend.surface1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent
            spacing: Scaler.s(8)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: btn.icon
                font.family: ThemeBackend.fontFamily
                font.pixelSize: Scaler.s(32)
                color: mouse.containsMouse ? btn.accentColor : ThemeBackend.text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: btn.label
                font.family: ThemeBackend.fontFamily
                font.pixelSize: Scaler.s(12)
                color: ThemeBackend.subtext0
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    IpcHandler {
        target: "powermenu"
        function toggle(): void { root.menuVisible = !root.menuVisible; }
        function close(): void { root.menuVisible = false; }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: menuWindow
                required property var modelData
                screen: modelData
                visible: root.menuVisible

                anchors { top: true; bottom: true; left: true; right: true }
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "logout_dialog"
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 0
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                onVisibleChanged: if (visible) overlayRect.forceActiveFocus()

                Rectangle {
                    id: overlayRect
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.55)
                    focus: true

                    Keys.onEscapePressed: root.menuVisible = false
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_L) lockBtn.activated();
                        else if (event.key === Qt.Key_R) rebootBtn.activated();
                        else if (event.key === Qt.Key_S) shutdownBtn.activated();
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.menuVisible = false
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: Scaler.s(24)

                        PowerMenuButton {
                            id: lockBtn
                            icon: "󰌾"
                            label: "Lock"
                            onActivated: {
                                Quickshell.execDetached(["bash", "-c", "pidof hyprlock || hyprlock"]);
                                root.menuVisible = false;
                            }
                        }
                        PowerMenuButton {
                            id: logoutBtn
                            icon: "󰍃"
                            label: "Logout"
                            onActivated: {
                                Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
                                root.menuVisible = false;
                            }
                        }
                        PowerMenuButton {
                            id: rebootBtn
                            icon: "󰜉"
                            label: "Reboot"
                            onActivated: {
                                Quickshell.execDetached(["systemctl", "reboot"]);
                                root.menuVisible = false;
                            }
                        }
                        PowerMenuButton {
                            id: shutdownBtn
                            icon: "󰐥"
                            label: "Shutdown"
                            accentColor: ThemeBackend.red
                            onActivated: {
                                Quickshell.execDetached(["systemctl", "poweroff"]);
                                root.menuVisible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
