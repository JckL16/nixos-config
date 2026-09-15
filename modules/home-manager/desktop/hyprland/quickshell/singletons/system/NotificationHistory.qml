pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: notif => {
            notif.tracked = !root.dndEnabled;
            root.addToHistory(notif);
            root.unreadCount += 1;
        }
    }

    readonly property alias trackedNotifications: server.trackedNotifications

    property var history: []
    property int unreadCount: 0
    property bool dndEnabled: false

    function toggleDnd() {
        dndEnabled = !dndEnabled;
    }

    function addToHistory(notif) {
        let entry = {
            appName: notif.appName,
            appIcon: notif.appIcon,
            summary: notif.summary,
            body: notif.body,
            image: notif.image,
            urgency: notif.urgency,
            time: Qt.formatDateTime(new Date(), "HH:mm")
        };
        let next = history.slice();
        next.unshift(entry);
        if (next.length > 50) next = next.slice(0, 50);
        history = next;
    }

    function clearHistory() {
        history = [];
    }

    function markRead() {
        unreadCount = 0;
    }
}
