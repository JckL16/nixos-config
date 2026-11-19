import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../reusables"
import "../../"

Rectangle {
    id: kbLayoutWidgetRoot
    property var barWindow
    property bool moduleActive: true

    property string layoutCode: "??"
    property string mainKbName: ""

    readonly property var knownLayoutCodes: ({
        "english": "US", "swedish": "SE", "german": "DE", "french": "FR",
        "spanish": "ES", "italian": "IT", "norwegian": "NO", "danish": "DK",
        "finnish": "FI", "russian": "RU", "polish": "PL", "portuguese": "PT",
        "dutch": "NL", "japanese": "JP", "ukrainian": "UA"
    })

    function codeFor(fullName) {
        if (!fullName) return "??";
        const parenMatch = fullName.match(/\(([^)]+)\)/);
        if (parenMatch) return parenMatch[1].toUpperCase().slice(0, 3);
        const lower = fullName.toLowerCase().trim();
        if (kbLayoutWidgetRoot.knownLayoutCodes[lower]) return kbLayoutWidgetRoot.knownLayoutCodes[lower];
        return fullName.slice(0, 2).toUpperCase();
    }

    Component.onCompleted: devicesProc.running = true;

    Process {
        id: devicesProc
        running: false
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const kbs = data.keyboards || [];
                    const kb = kbs.find(k => k.main) || kbs[0];
                    if (kb) {
                        kbLayoutWidgetRoot.mainKbName = kb.name;
                        kbLayoutWidgetRoot.layoutCode = kbLayoutWidgetRoot.codeFor(kb.active_keymap);
                    }
                } catch (e) {}
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const sepIdx = event.data.lastIndexOf(",");
                const devName = sepIdx >= 0 ? event.data.slice(0, sepIdx) : "";
                const layoutName = sepIdx >= 0 ? event.data.slice(sepIdx + 1) : event.data;
                if (devName === kbLayoutWidgetRoot.mainKbName) {
                    kbLayoutWidgetRoot.layoutCode = kbLayoutWidgetRoot.codeFor(layoutName);
                }
            }
        }
    }

    property real targetX: 0
    x: targetX
    height: barWindow ? barWindow.barHeight : 30
    y: barWindow ? barWindow.baseOffsetY : 0
    radius: ThemeBackend.borderRadius
    color: "transparent"
    clip: true

    property real targetWidth: (moduleActive && kbLayout.implicitWidth > 0) ? (kbLayout.implicitWidth + barWindow.s(10)) : 0
    width: targetWidth

    opacity: moduleActive ? ((barWindow && barWindow.barOpacity !== undefined) ? barWindow.barOpacity : 1.0) : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Row {
        id: kbLayout
        anchors.centerIn: parent

        ClickButton {
            id: kbPill
            height: barWindow ? barWindow.s(30) : 30
            cornerRadius: Math.max(0, ThemeBackend.borderRadius - (barWindow ? barWindow.s(2) : 2))
            horizontalPadding: barWindow ? barWindow.s(4) : 4
            buttonIcon: "󰌌"
            iconFontSize: barWindow ? barWindow.s(15) : 15
            buttonText: kbLayoutWidgetRoot.layoutCode
            textFontSize: barWindow ? barWindow.s(12) : 12
            accentColor: "transparent"
            textColor: ThemeBackend.text

            width: implicitWidth
            Behavior on width { NumberAnimation { duration: 480; easing.type: Easing.OutQuint } }

            onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "current", "next"])
        }
    }
}
