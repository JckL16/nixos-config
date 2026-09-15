import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../"

Rectangle {
    id: notifRoot
    property var barWindow
    property bool moduleActive: true

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    color: "transparent"

    property real targetWidth: (moduleActive && bellPill.implicitWidth > 0) ? bellPill.implicitWidth : 0
    width: targetWidth

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bellPill
        implicitWidth: bellRow.implicitWidth + (barWindow ? barWindow.s(14) : 14)
        height: barWindow ? barWindow.s(30) : 30
        radius: ThemeBackend.borderRadius
        color: "transparent"

        RowLayout {
            id: bellRow
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: NotificationHistory.dndEnabled ? "󰂛" : (NotificationHistory.history.length > 0 ? "󰂚" : "󰂜")
                font.family: ThemeBackend.fontFamily
                font.pixelSize: barWindow ? barWindow.s(13) : 13
                color: NotificationHistory.dndEnabled ? ThemeBackend.overlay1 : ThemeBackend.subtext0
            }
            Text {
                visible: NotificationHistory.unreadCount > 0
                text: NotificationHistory.unreadCount
                font.family: ThemeBackend.fontFamily
                font.pixelSize: barWindow ? barWindow.s(10) : 10
                font.bold: true
                color: ThemeBackend.mauve
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    NotificationHistory.toggleDnd();
                    return;
                }
                historyPopup.visible = !historyPopup.visible;
                if (historyPopup.visible) NotificationHistory.markRead();
            }
        }
    }

    PopupWindow {
        id: historyPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(300) : 300
        implicitHeight: Math.min((barWindow ? barWindow.s(400) : 400), popupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16))

        anchor.item: bellPill
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

            Flickable {
                anchors.fill: parent
                anchors.margins: barWindow ? barWindow.s(8) : 8
                contentWidth: width
                contentHeight: popupContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: popupContent
                    width: parent.width
                    spacing: barWindow ? barWindow.s(8) : 8

                    RowLayout {
                        width: parent.width

                        Text {
                            text: "Notifications"
                            font.family: ThemeBackend.fontFamily
                            font.weight: Font.Bold
                            font.pixelSize: barWindow ? barWindow.s(12) : 12
                            color: ThemeBackend.text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            visible: NotificationHistory.history.length > 0
                            text: "Clear all"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(10) : 10
                            color: ThemeBackend.subtext0
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NotificationHistory.clearHistory()
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                    RowLayout {
                        width: parent.width

                        Text {
                            text: "Do not disturb"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(11) : 11
                            color: ThemeBackend.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            id: dndToggle
                            Layout.preferredWidth: barWindow ? barWindow.s(32) : 32
                            Layout.preferredHeight: barWindow ? barWindow.s(18) : 18
                            radius: height / 2
                            color: NotificationHistory.dndEnabled ? ThemeBackend.overlay1 : ThemeBackend.surface1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                width: parent.height - (barWindow ? barWindow.s(4) : 4)
                                height: width
                                radius: width / 2
                                anchors.verticalCenter: parent.verticalCenter
                                x: NotificationHistory.dndEnabled ? parent.width - width - (barWindow ? barWindow.s(2) : 2) : (barWindow ? barWindow.s(2) : 2)
                                color: ThemeBackend.base

                                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NotificationHistory.toggleDnd()
                            }
                        }
                    }

                    Text {
                        visible: NotificationHistory.history.length === 0
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "No notifications"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                        topPadding: barWindow ? barWindow.s(12) : 12
                        bottomPadding: barWindow ? barWindow.s(12) : 12
                    }

                    Repeater {
                        model: NotificationHistory.history

                        delegate: Rectangle {
                            id: histItem
                            required property var modelData
                            width: popupContent.width
                            implicitHeight: histLayout.implicitHeight + (barWindow ? barWindow.s(12) : 12)
                            radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                            color: histMouse.containsMouse ? ThemeBackend.surface1 : ThemeBackend.surface0

                            Behavior on color { ColorAnimation { duration: 120 } }

                            MouseArea {
                                id: histMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (histItem.modelData.appName) {
                                        Hyprland.dispatch("focuswindow class:(?i)" + histItem.modelData.appName);
                                    }
                                }
                            }

                            RowLayout {
                                id: histLayout
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: barWindow ? barWindow.s(8) : 8
                                anchors.rightMargin: barWindow ? barWindow.s(8) : 8
                                spacing: 6

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            text: modelData.summary
                                            font.family: ThemeBackend.fontFamily
                                            font.weight: Font.Bold
                                            font.pixelSize: barWindow ? barWindow.s(11) : 11
                                            color: ThemeBackend.text
                                        }
                                        Text {
                                            text: modelData.time
                                            font.family: ThemeBackend.fontFamily
                                            font.pixelSize: barWindow ? barWindow.s(9) : 9
                                            color: ThemeBackend.overlay1
                                        }
                                    }
                                    Text {
                                        visible: modelData.body !== ""
                                        Layout.fillWidth: true
                                        text: modelData.body
                                        textFormat: Text.PlainText
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: barWindow ? barWindow.s(10) : 10
                                        color: ThemeBackend.subtext0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
