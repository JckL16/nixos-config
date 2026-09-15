import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Item {
    id: root

    PanelWindow {
        id: notifWindow
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        visible: NotificationHistory.trackedNotifications.values.length > 0

        anchors { top: true; right: true }
        exclusiveZone: 0
        color: "transparent"
        margins {
            top: Scaler.s(0)
            right: Scaler.s(8)
        }
        implicitWidth: Scaler.s(300)
        implicitHeight: notifColumn.implicitHeight

        Column {
            id: notifColumn
            width: parent.width
            spacing: Scaler.s(8)

            Repeater {
                model: NotificationHistory.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    readonly property bool isCritical: modelData.urgency === NotificationUrgency.Critical

                    width: notifColumn.width
                    implicitHeight: cardLayout.implicitHeight + Scaler.s(20)
                    radius: ThemeBackend.borderRadius
                    color: ThemeBackend.mantle
                    border.width: 1
                    border.color: card.isCritical ? ThemeBackend.red : ThemeBackend.surface1

                    Timer {
                        running: !card.isCritical
                        interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 6000
                        onTriggered: card.modelData.expire()
                    }

                    RowLayout {
                        id: cardLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Scaler.s(10)
                        anchors.rightMargin: Scaler.s(10)
                        spacing: Scaler.s(8)

                        Rectangle {
                            Layout.preferredWidth: Scaler.s(32)
                            Layout.preferredHeight: Scaler.s(32)
                            radius: Scaler.s(8)
                            color: ThemeBackend.surface0
                            clip: true

                            Text {
                                anchors.centerIn: parent
                                visible: !iconImg.visible
                                text: "󰂚"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: Scaler.s(16)
                                color: ThemeBackend.subtext0
                            }
                            Image {
                                id: iconImg
                                anchors.fill: parent
                                visible: source !== "" && status === Image.Ready
                                source: card.modelData.image !== "" ? card.modelData.image : (card.modelData.appIcon !== "" ? Quickshell.iconPath(card.modelData.appIcon, true) : "")
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: card.modelData.summary
                                font.family: ThemeBackend.fontFamily
                                font.weight: Font.Bold
                                font.pixelSize: Scaler.s(12)
                                color: ThemeBackend.text
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: card.modelData.body !== ""
                                text: card.modelData.body
                                textFormat: Text.PlainText
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: Scaler.s(10)
                                color: ThemeBackend.subtext0
                            }

                            Row {
                                Layout.topMargin: Scaler.s(4)
                                spacing: Scaler.s(6)
                                visible: card.modelData.actions.length > 0

                                Repeater {
                                    model: card.modelData.actions
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: actionText.implicitWidth + Scaler.s(12)
                                        height: Scaler.s(20)
                                        radius: Scaler.s(6)
                                        color: ThemeBackend.surface0

                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            font.family: ThemeBackend.fontFamily
                                            font.pixelSize: Scaler.s(10)
                                            color: ThemeBackend.text
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: "󰅖"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: Scaler.s(12)
                            color: ThemeBackend.overlay1
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: card.modelData.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}
