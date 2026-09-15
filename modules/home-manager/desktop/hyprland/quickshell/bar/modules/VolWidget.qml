import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../../reusables"
import "../../"

Rectangle {
    id: volWidgetRoot
    property var barWindow
    property bool isSolid: false
    property bool distinctPills: barWindow ? (barWindow.distinctPills !== undefined ? barWindow.distinctPills : false) : false
    property bool moduleActive: true
    property bool isGrouped: false
    property bool isCompact: isGrouped || (isSolid && distinctPills)

    property real sysVolume: Audio.defaultSink && Audio.defaultSink.audio ? Math.round(Audio.defaultSink.audio.volume * 100) : 0
    property bool isMuted: Audio.defaultSink && Audio.defaultSink.audio ? Audio.defaultSink.audio.muted : false
    property string volPercent: sysVolume + "%"
    property string volIcon: isMuted || sysVolume === 0 ? "󰖁" : (sysVolume > 50 ? "󰕾" : "󰖀")
    property bool isSoundActive: !isMuted && sysVolume > 0

    property real targetX: 0
    property bool showLayout: false

    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    radius: ThemeBackend.borderRadius
    border.width: 0
    color: "transparent"
    clip: true

    property real targetWidth: (moduleActive && sysLayout.implicitWidth > 0) ? (sysLayout.implicitWidth + barWindow.s(isCompact ? 8 : 10)) : 0
    width: targetWidth

    opacity: (showLayout && moduleActive) ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Timer {
        running: volWidgetRoot.moduleActive && barWindow
        interval: 100
        onTriggered: volWidgetRoot.showLayout = true
    }

    Row {
        id: sysLayout
        anchors.centerIn: parent
        property int pillHeight: barWindow ? barWindow.s(volWidgetRoot.isCompact ? 28 : 30) : (volWidgetRoot.isCompact ? 28 : 30)

        ClickButton {
            id: volPill
            height: sysLayout.pillHeight
            maxWidth: barWindow ? barWindow.s(volWidgetRoot.isCompact ? 96 : 100) : (volWidgetRoot.isCompact ? 96 : 100)
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(2) : 2))
            horizontalPadding: barWindow ? barWindow.s(volWidgetRoot.isCompact ? 2 : 4) : (volWidgetRoot.isCompact ? 2 : 4)
            buttonIcon: volIcon
            iconFontSize: barWindow ? barWindow.s(volWidgetRoot.isCompact ? 14 : 15) : (volWidgetRoot.isCompact ? 14 : 15)
            buttonText: volPercent
            textFontSize: barWindow ? barWindow.s(volWidgetRoot.isCompact ? 11 : 12) : (volWidgetRoot.isCompact ? 11 : 12)
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            accentColor: "transparent"
            textColor: ThemeBackend.text

            width: implicitWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            onClicked: volPopup.visible = !volPopup.visible
            onRightClicked: if (Audio.defaultSink) Audio.toggleMute(Audio.defaultSink)

            property real wheelAccumulator: 0
            Timer {
                id: volWheelTimer
                interval: 200
                onTriggered: volPill.wheelAccumulator = 0
            }

            onWheel: wheel => {
                volWheelTimer.restart()
                volPill.wheelAccumulator += wheel.angleDelta.y
                const threshold = 120
                if (Math.abs(volPill.wheelAccumulator) >= threshold) {
                    let steps = Math.trunc(volPill.wheelAccumulator / threshold)
                    volPill.wheelAccumulator = volPill.wheelAccumulator % threshold
                    if (steps !== 0 && Audio.defaultSink) {
                        let newVol = Math.max(0, Math.min(100, volWidgetRoot.sysVolume + (steps * 5)))
                        Audio.setVolume(Audio.defaultSink, newVol)
                    }
                }
            }
        }
    }

    PopupWindow {
        id: volPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(240) : 240
        implicitHeight: popupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16)

        anchor.item: volPill
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
                id: popupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(10) : 10

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: volWidgetRoot.volIcon
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(16) : 16
                        color: ThemeBackend.text
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (Audio.defaultSink) Audio.toggleMute(Audio.defaultSink)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Volume"
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: barWindow ? barWindow.s(12) : 12
                        color: ThemeBackend.text
                    }

                    Text {
                        text: volWidgetRoot.volPercent
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(12) : 12
                        color: ThemeBackend.subtext0
                    }
                }

                Rectangle {
                    id: sliderTrack
                    width: parent.width
                    height: barWindow ? barWindow.s(10) : 10
                    radius: height / 2
                    color: ThemeBackend.surface0

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, volWidgetRoot.sysVolume / 100))
                        height: parent.height
                        radius: height / 2
                        color: ThemeBackend.mauve
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: mouse => sliderTrack.setFromX(mouse.x)
                        onPositionChanged: mouse => { if (pressed) sliderTrack.setFromX(mouse.x); }
                    }

                    function setFromX(x) {
                        if (!Audio.defaultSink) return;
                        let pct = Math.max(0, Math.min(100, Math.round((x / width) * 100)));
                        Audio.setVolume(Audio.defaultSink, pct);
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Text {
                    text: "Output"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(10) : 10
                    color: ThemeBackend.subtext0
                }

                Repeater {
                    model: Audio.outputs

                    delegate: Column {
                        required property var modelData
                        width: popupContent.width
                        spacing: barWindow ? barWindow.s(4) : 4

                        Rectangle {
                            width: parent.width
                            height: barWindow ? barWindow.s(28) : 28
                            radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                            color: (Audio.defaultSink === modelData) ? ThemeBackend.surface1 : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: Audio.getNodeName(modelData)
                                elide: Text.ElideRight
                                width: parent.width - 16
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: (Audio.defaultSink === modelData) ? ThemeBackend.text : ThemeBackend.subtext0
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Audio.setDefaultOutput(modelData)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                Text {
                    text: "Input"
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(10) : 10
                    color: ThemeBackend.subtext0
                }

                Repeater {
                    model: Audio.inputs

                    delegate: Column {
                        required property var modelData
                        width: popupContent.width
                        spacing: barWindow ? barWindow.s(4) : 4

                        Rectangle {
                            width: parent.width
                            height: barWindow ? barWindow.s(28) : 28
                            radius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(4) : 4))
                            color: (Audio.defaultSource === modelData) ? ThemeBackend.surface1 : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: Audio.getNodeName(modelData)
                                elide: Text.ElideRight
                                width: parent.width - 16
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: (Audio.defaultSource === modelData) ? ThemeBackend.text : ThemeBackend.subtext0
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Audio.setDefaultInput(modelData)
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
                        text: "Open Mixer"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["alacritty", "--class", "quickshell-mixer", "-e", "wiremix"]);
                            volPopup.visible = false;
                        }
                    }
                }
            }
        }
    }
}
