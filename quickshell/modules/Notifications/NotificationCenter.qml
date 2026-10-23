// modules/Notifications/NotificationCenter.qml
// Listens to DBus notifications and displays them as toasts

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../../config"

Item {
    id: root

    // ─── Notification server ────────────────────────────────
    NotificationServer {
        id: server
        actionsSupported:     true
        bodySupported:        true
        bodyImagesSupported:  false
        persistenceSupported: true
        imageSupported:       true

        onNotification: (notif) => {
            notifModel.insert(0, {
                "summary":  notif.summary,
                "body":     notif.body,
                "appName":  notif.appName,
                "urgency":  notif.urgency,
                "id":       notif.id
            })
            // Auto-dismiss low/normal urgency after 5 s
            if (notif.urgency !== NotificationUrgency.Critical) {
                Qt.createQmlObject(
                    'import QtQuick; Timer { interval: 5000; running: true; ' +
                    'onTriggered: notifModel.remove(0) }',
                    root
                )
            }
        }
    }

    ListModel { id: notifModel }

    // ─── Toast column (top-right) ───────────────────────────
    Column {
        anchors {
            top:   parent.top
            right: parent.right
            topMargin:   48
            rightMargin: 16
        }
        spacing: 8

        Repeater {
            model: notifModel

            delegate: NotificationItem {
                summary: model.summary
                body:    model.body
                appName: model.appName
                urgency: model.urgency
                onDismissed: notifModel.remove(index)
            }
        }
    }
}
