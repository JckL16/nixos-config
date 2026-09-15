import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../"

Rectangle {
    id: clockRoot

    property var barWindow
    property bool moduleActive: true

    property var eventsByDate: ({})

    function refreshEvents() {
        eventsProc.running = false;
        eventsProc.running = true;
    }

    Process {
        id: eventsProc
        running: false
        command: ["eds-calendar-events"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(text);
                    let map = {};
                    for (let i = 0; i < list.length; i++) {
                        let ev = list[i];
                        if (!map[ev.date]) map[ev.date] = [];
                        map[ev.date].push(ev);
                    }
                    for (let date in map) {
                        map[date].sort((a, b) => (a.time || "").localeCompare(b.time || ""));
                    }
                    clockRoot.eventsByDate = map;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clockRoot.refreshEvents()
    }

    property var now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clockRoot.now = new Date()
    }

    function isoWeekNumber(date) {
        let d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        let dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        let yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
        return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
    }

    readonly property int weekNumber: isoWeekNumber(now)
    readonly property string timeStr: "V" + weekNumber + "  " + Qt.formatDateTime(now, "yyyy-MM-dd") + "  " + Qt.formatDateTime(now, "HH:mm")

    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    radius: ThemeBackend.borderRadius
    color: "transparent"
    border.width: 0

    property real horizontalPadding: barWindow ? barWindow.s(4) : 4
    width: label.implicitWidth + horizontalPadding * 2

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Text {
        id: label
        anchors.centerIn: parent
        text: clockRoot.timeStr
        font.family: ThemeBackend.fontFamily
        font.pixelSize: barWindow ? barWindow.s(13) : 13
        font.weight: Font.Bold
        color: ThemeBackend.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: calPopup.visible = !calPopup.visible
    }

    PopupWindow {
        id: calPopup
        visible: false
        color: "transparent"
        implicitWidth: barWindow ? barWindow.s(320) : 320
        implicitHeight: calContent.implicitHeight + (barWindow ? barWindow.s(20) : 20)

        anchor.item: clockRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.All

        grabFocus: true

        onVisibleChanged: if (visible) clockRoot.refreshEvents()

        property string selectedDate: ""
        property int viewYear: clockRoot.now.getFullYear()
        property int viewMonth: clockRoot.now.getMonth()

        function shiftMonth(delta) {
            let m = calPopup.viewMonth + delta;
            let y = calPopup.viewYear;
            if (m < 0) { m = 11; y -= 1; }
            else if (m > 11) { m = 0; y += 1; }
            calPopup.viewMonth = m;
            calPopup.viewYear = y;
        }

        function buildWeeks(year, month) {
            let firstOfMonth = new Date(year, month, 1);
            let startOffset = (firstOfMonth.getDay() + 6) % 7; // Monday = 0
            let daysInMonth = new Date(year, month + 1, 0).getDate();
            let gridStart = new Date(year, month, 1 - startOffset);

            let today = new Date();
            let weeks = [];
            let cursor = new Date(gridStart);
            for (let w = 0; w < 6; w++) {
                let days = [];
                for (let d = 0; d < 7; d++) {
                    let mm = String(cursor.getMonth() + 1).padStart(2, "0");
                    let dd = String(cursor.getDate()).padStart(2, "0");
                    days.push({
                        day: cursor.getDate(),
                        dateStr: cursor.getFullYear() + "-" + mm + "-" + dd,
                        inMonth: cursor.getMonth() === month,
                        isToday: cursor.getFullYear() === today.getFullYear() && cursor.getMonth() === today.getMonth() && cursor.getDate() === today.getDate()
                    });
                    cursor.setDate(cursor.getDate() + 1);
                }
                weeks.push({ week: clockRoot.isoWeekNumber(new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate() - 1)), days: days });
            }
            return weeks;
        }

        readonly property var weeks: buildWeeks(viewYear, viewMonth)
        readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

        Rectangle {
            anchors.fill: parent
            radius: ThemeBackend.borderRadius
            color: ThemeBackend.mantle
            border.width: 1
            border.color: ThemeBackend.surface1

            Column {
                id: calContent
                anchors.centerIn: parent
                width: parent.width - (barWindow ? barWindow.s(20) : 20)
                spacing: barWindow ? barWindow.s(10) : 10

                Column {
                    width: parent.width
                    spacing: 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clockRoot.now, "HH:mm:ss")
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Black
                        font.pixelSize: barWindow ? barWindow.s(30) : 30
                        color: ThemeBackend.text
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clockRoot.now, "dddd, MMMM d yyyy") + "  ·  Week " + clockRoot.weekNumber
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.subtext0
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                RowLayout {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "‹"
                        font.pixelSize: barWindow ? barWindow.s(16) : 16
                        color: ThemeBackend.subtext0
                        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: calPopup.shiftMonth(-1) }
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: calPopup.monthNames[calPopup.viewMonth] + " " + calPopup.viewYear
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: barWindow ? barWindow.s(13) : 13
                        color: ThemeBackend.text
                    }
                    Text {
                        text: "›"
                        font.pixelSize: barWindow ? barWindow.s(16) : 16
                        color: ThemeBackend.subtext0
                        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: calPopup.shiftMonth(1) }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 3

                    Text {
                        text: "Wk"
                        Layout.preferredWidth: barWindow ? barWindow.s(26) : 26
                        horizontalAlignment: Text.AlignHCenter
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(10) : 10
                        color: ThemeBackend.overlay1
                    }
                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                        delegate: Text {
                            required property string modelData
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.family: ThemeBackend.fontFamily
                            font.weight: Font.Bold
                            font.pixelSize: barWindow ? barWindow.s(10) : 10
                            color: ThemeBackend.overlay1
                        }
                    }
                }

                Repeater {
                    model: calPopup.weeks
                    delegate: RowLayout {
                        required property var modelData
                        width: calContent.width
                        spacing: 3

                        Text {
                            text: modelData.week
                            Layout.preferredWidth: barWindow ? barWindow.s(26) : 26
                            horizontalAlignment: Text.AlignHCenter
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: barWindow ? barWindow.s(10) : 10
                            color: ThemeBackend.overlay1
                        }
                        Repeater {
                            model: modelData.days
                            delegate: Rectangle {
                                id: dayCell
                                required property var modelData
                                readonly property var dayEvents: clockRoot.eventsByDate[modelData.dateStr] || []
                                readonly property bool isSelected: calPopup.selectedDate === modelData.dateStr
                                Layout.fillWidth: true
                                Layout.preferredHeight: barWindow ? barWindow.s(30) : 30
                                radius: height / 2
                                color: modelData.isToday ? ThemeBackend.mauve : (isSelected ? ThemeBackend.surface1 : (dayMouse.containsMouse ? ThemeBackend.surface0 : "transparent"))

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: dayCell.modelData.day
                                    font.family: ThemeBackend.fontFamily
                                    font.weight: dayCell.modelData.isToday ? Font.Bold : Font.Normal
                                    font.pixelSize: barWindow ? barWindow.s(8) : 8
                                    color: dayCell.modelData.isToday ? ThemeBackend.base : (dayCell.modelData.inMonth ? ThemeBackend.text : ThemeBackend.overlay0)
                                }

                                Rectangle {
                                    visible: dayCell.dayEvents.length > 0
                                    width: barWindow ? barWindow.s(4) : 4
                                    height: width
                                    radius: width / 2
                                    color: dayCell.modelData.isToday ? ThemeBackend.base : ThemeBackend.mauve
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: barWindow ? barWindow.s(3) : 3
                                }

                                MouseArea {
                                    id: dayMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: calPopup.selectedDate = (calPopup.selectedDate === dayCell.modelData.dateStr) ? "" : dayCell.modelData.dateStr
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 4
                    visible: calPopup.selectedDate !== ""

                    Rectangle { width: parent.width; height: 1; color: ThemeBackend.surface0 }

                    Text {
                        text: calPopup.selectedDate
                        font.family: ThemeBackend.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: barWindow ? barWindow.s(11) : 11
                        color: ThemeBackend.text
                    }

                    Repeater {
                        model: clockRoot.eventsByDate[calPopup.selectedDate] || []
                        delegate: Column {
                            id: eventDelegate
                            required property var modelData
                            required property int index
                            width: calContent.width
                            spacing: 2

                            Item {
                                visible: eventDelegate.index > 0
                                width: 1
                                height: barWindow ? barWindow.s(6) : 6
                            }

                            Rectangle {
                                visible: eventDelegate.index > 0
                                width: parent.width
                                height: 1
                                color: ThemeBackend.surface0
                            }

                            Text {
                                width: eventDelegate.width
                                wrapMode: Text.WordWrap
                                text: (eventDelegate.modelData.calendar ? eventDelegate.modelData.calendar + " - " : "") + eventDelegate.modelData.summary
                                font.family: ThemeBackend.fontFamily
                                font.weight: Font.Bold
                                font.pixelSize: barWindow ? barWindow.s(13) : 13
                                color: ThemeBackend.subtext0
                            }

                            Text {
                                visible: !!eventDelegate.modelData.time
                                leftPadding: barWindow ? barWindow.s(14) : 14
                                text: eventDelegate.modelData.time
                                    + (eventDelegate.modelData.endTime ? "  –  " + eventDelegate.modelData.endTime : "")
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: ThemeBackend.overlay1
                            }

                            Text {
                                id: locationText
                                readonly property bool isUrl: /^https?:\/\//.test(eventDelegate.modelData.location || "")
                                visible: eventDelegate.modelData.location && eventDelegate.modelData.location.length > 0
                                leftPadding: barWindow ? barWindow.s(14) : 14
                                width: eventDelegate.width
                                wrapMode: Text.WordWrap
                                textFormat: Text.StyledText
                                text: {
                                    let loc = eventDelegate.modelData.location || "";
                                    let escaped = loc.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                                    return "at " + (locationText.isUrl ? ("<a href=\"" + loc + "\">" + escaped + "</a>") : escaped);
                                }
                                onLinkActivated: (link) => Qt.openUrlExternally(link)
                                linkColor: ThemeBackend.blue
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: barWindow ? barWindow.s(11) : 11
                                color: ThemeBackend.overlay1

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton
                                    cursorShape: locationText.isUrl ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }
                            }
                        }
                    }

                    Text {
                        visible: (clockRoot.eventsByDate[calPopup.selectedDate] || []).length === 0
                        text: "No events"
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: barWindow ? barWindow.s(10) : 10
                        color: ThemeBackend.overlay1
                    }
                }
            }
        }
    }
}
