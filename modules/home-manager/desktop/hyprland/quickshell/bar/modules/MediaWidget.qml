import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../../"

Rectangle {
    id: mediaRoot
    property var barWindow
    property bool moduleActive: true

    property string manualPlayerName: ""

    readonly property MprisPlayer player: {
        let players = Mpris.players.values;
        if (mediaRoot.manualPlayerName !== "") {
            let manual = players.find(p => p.dbusName === mediaRoot.manualPlayerName);
            if (manual) return manual;
        }
        let playing = players.find(p => p.isPlaying);
        if (playing) return playing;
        let controllable = players.find(p => p.canControl);
        if (controllable) return controllable;
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool isActive: player !== null && player.trackTitle !== ""
    readonly property bool isPlaying: player !== null && player.isPlaying

    Timer {
        interval: 1000
        repeat: true
        running: mediaRoot.isPlaying
        onTriggered: if (mediaRoot.player) mediaRoot.player.positionChanged()
    }

    function fmtTime(sec) {
        sec = Math.floor(sec || 0);
        let m = Math.floor(sec / 60), s = sec % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    radius: ThemeBackend.borderRadius
    color: "transparent"

    property real targetWidth: (moduleActive && mediaRoot.isActive && mediaLayout.implicitWidth > 0) ? (mediaLayout.implicitWidth + barWindow.s(8)) : 0
    width: targetWidth
    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    clip: true

    opacity: (moduleActive && mediaRoot.isActive) ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    RowLayout {
        id: mediaLayout
        anchors.centerIn: parent
        spacing: barWindow ? barWindow.s(10) : 10

        Rectangle {
            id: artBox
            width: barWindow ? barWindow.s(28) : 28
            height: barWindow ? barWindow.s(28) : 28
            radius: barWindow ? barWindow.s(7) : 7
            color: ThemeBackend.surface0
            clip: true

            Text {
                anchors.centerIn: parent
                visible: !artImg.visible
                text: "󰎈"
                font.family: ThemeBackend.fontFamily
                font.pixelSize: barWindow ? barWindow.s(15) : 15
                color: ThemeBackend.subtext0
            }

            Image {
                id: artImg
                anchors.fill: parent
                visible: mediaRoot.player && mediaRoot.player.trackArtUrl !== "" && status === Image.Ready
                source: mediaRoot.player ? mediaRoot.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mediaPopup.visible = !mediaPopup.visible
            }
        }

        Item {
            Layout.preferredWidth: barWindow ? barWindow.s(170) : 170
            Layout.fillHeight: true

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 0

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: {
                        if (!mediaRoot.player) return "";
                        let t = mediaRoot.player.trackTitle || "";
                        let a = mediaRoot.player.trackArtist || "";
                        return a !== "" ? (t + " - " + a) : t;
                    }
                    font.family: ThemeBackend.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: barWindow ? barWindow.s(11) : 11
                    color: ThemeBackend.text
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: mediaRoot.player ? (mediaRoot.fmtTime(mediaRoot.player.position) + " / " + mediaRoot.fmtTime(mediaRoot.player.length)) : ""
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(9) : 9
                    color: ThemeBackend.subtext0
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mediaPopup.visible = !mediaPopup.visible
            }
        }

        RowLayout {
            spacing: barWindow ? barWindow.s(2) : 2

            Rectangle {
                Layout.preferredWidth: barWindow ? barWindow.s(24) : 24
                Layout.preferredHeight: barWindow ? barWindow.s(24) : 24
                radius: width / 2
                color: prevMa.containsMouse ? ThemeBackend.surface0 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(14) : 14
                    color: (mediaRoot.player && mediaRoot.player.canGoPrevious) ? ThemeBackend.text : ThemeBackend.overlay0
                }
                MouseArea {
                    id: prevMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (mediaRoot.player && mediaRoot.player.canGoPrevious) mediaRoot.player.previous()
                }
            }
            Rectangle {
                Layout.preferredWidth: barWindow ? barWindow.s(24) : 24
                Layout.preferredHeight: barWindow ? barWindow.s(24) : 24
                radius: width / 2
                color: playMa.containsMouse ? ThemeBackend.surface0 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: mediaRoot.isPlaying ? "󰏤" : "󰐊"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(16) : 16
                    color: ThemeBackend.text
                }
                MouseArea {
                    id: playMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (mediaRoot.player && mediaRoot.player.canTogglePlaying) mediaRoot.player.togglePlaying()
                }
            }
            Rectangle {
                Layout.preferredWidth: barWindow ? barWindow.s(24) : 24
                Layout.preferredHeight: barWindow ? barWindow.s(24) : 24
                radius: width / 2
                color: nextMa.containsMouse ? ThemeBackend.surface0 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: barWindow ? barWindow.s(14) : 14
                    color: (mediaRoot.player && mediaRoot.player.canGoNext) ? ThemeBackend.text : ThemeBackend.overlay0
                }
                MouseArea {
                    id: nextMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (mediaRoot.player && mediaRoot.player.canGoNext) mediaRoot.player.next()
                }
            }
        }
    }

    PopupWindow {
        id: mediaPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(280) : 280
        implicitHeight: popupContent.implicitHeight + (barWindow ? barWindow.s(16) : 16) + topGap

        property real topGap: barWindow ? barWindow.s(8) : 8

        anchor.item: mediaRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.All

        grabFocus: true

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.topMargin: mediaPopup.topGap
            radius: ThemeBackend.borderRadius
            color: ThemeBackend.mantle
            border.width: 1
            border.color: ThemeBackend.surface1

            Column {
                id: popupContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(16) : 16)
                spacing: barWindow ? barWindow.s(10) : 10

                Rectangle {
                    width: barWindow ? barWindow.s(180) : 180
                    height: barWindow ? barWindow.s(180) : 180
                    radius: barWindow ? barWindow.s(16) : 16
                    color: ThemeBackend.surface0
                    clip: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        visible: !popupArt.visible
                        text: "󰎈"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(36) : 36
                        color: ThemeBackend.subtext0
                    }
                    Image {
                        id: popupArt
                        anchors.fill: parent
                        visible: mediaRoot.player && mediaRoot.player.trackArtUrl !== "" && status === Image.Ready
                        source: mediaRoot.player ? mediaRoot.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: barWindow ? barWindow.s(6) : 6
                    visible: Mpris.players.values.length > 1

                    Repeater {
                        model: Mpris.players.values

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool isSelected: mediaRoot.player === modelData
                            width: playerLabel.implicitWidth + (barWindow ? barWindow.s(14) : 14)
                            height: barWindow ? barWindow.s(22) : 22
                            radius: height / 2
                            color: isSelected ? ThemeBackend.surface1 : ThemeBackend.surface0
                            border.width: isSelected ? 1 : 0
                            border.color: ThemeBackend.mauve

                            Text {
                                id: playerLabel
                                anchors.centerIn: parent
                                text: modelData.identity || "Player"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(10) : 10
                                color: parent.isSelected ? ThemeBackend.text : ThemeBackend.subtext0
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mediaRoot.manualPlayerName = modelData.dbusName
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 0
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: mediaRoot.player ? (mediaRoot.player.trackTitle || "Nothing playing") : "Nothing playing"
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: barWindow ? barWindow.s(13) : 13
                        color: ThemeBackend.text
                    }
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: mediaRoot.player ? (mediaRoot.player.trackArtist || "") : ""
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                    }
                }

                Column {
                    width: parent.width
                    spacing: 4
                    visible: mediaRoot.player !== null

                    Rectangle {
                        id: seekTrack
                        width: parent.width
                        height: barWindow ? barWindow.s(6) : 6
                        radius: height / 2
                        color: ThemeBackend.surface0

                        Rectangle {
                            width: (mediaRoot.player && mediaRoot.player.length > 0) ? parent.width * Math.max(0, Math.min(1, mediaRoot.player.position / mediaRoot.player.length)) : 0
                            height: parent.height
                            radius: height / 2
                            color: ThemeBackend.mauve
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: mediaRoot.player && mediaRoot.player.canSeek
                            onPressed: mouse => seekTrack.seekFromX(mouse.x)
                            onPositionChanged: mouse => { if (pressed) seekTrack.seekFromX(mouse.x); }
                        }

                        function seekFromX(x) {
                            if (!mediaRoot.player || !mediaRoot.player.canSeek || mediaRoot.player.length <= 0) return;
                            let frac = Math.max(0, Math.min(1, x / width));
                            mediaRoot.player.position = frac * mediaRoot.player.length;
                        }
                    }

                    RowLayout {
                        width: parent.width
                        Text {
                            text: mediaRoot.player ? mediaRoot.fmtTime(mediaRoot.player.position) : "0:00"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(9) : 9
                            color: ThemeBackend.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: mediaRoot.player ? mediaRoot.fmtTime(mediaRoot.player.length) : "0:00"
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(9) : 9
                            color: ThemeBackend.subtext0
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: barWindow ? barWindow.s(20) : 20

                    Text {
                        text: "󰒮"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(22) : 22
                        color: (mediaRoot.player && mediaRoot.player.canGoPrevious) ? ThemeBackend.text : ThemeBackend.overlay0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (mediaRoot.player && mediaRoot.player.canGoPrevious) mediaRoot.player.previous()
                        }
                    }
                    Text {
                        text: mediaRoot.isPlaying ? "󰏤" : "󰐊"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(28) : 28
                        color: ThemeBackend.text
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (mediaRoot.player && mediaRoot.player.canTogglePlaying) mediaRoot.player.togglePlaying()
                        }
                    }
                    Text {
                        text: "󰒭"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(22) : 22
                        color: (mediaRoot.player && mediaRoot.player.canGoNext) ? ThemeBackend.text : ThemeBackend.overlay0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (mediaRoot.player && mediaRoot.player.canGoNext) mediaRoot.player.next()
                        }
                    }
                }
            }
        }
    }
}
