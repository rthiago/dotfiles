import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Scope {
    id: root

    required property var hostWindow
    required property var theme

    property bool historyVisible: false

    PersistentProperties {
        id: history

        reloadableId: "notificationHistory"
        property bool available: false
        property string appName: ""
        property string summary: ""
        property string body: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: NotificationUrgency.Normal
        property double receivedAt: 0
    }

    QtObject {
        id: restoredNotification

        readonly property string appName: history.appName
        readonly property string summary: history.summary
        readonly property string body: history.body
        readonly property string appIcon: history.appIcon
        readonly property string image: history.image
        readonly property int urgency: history.urgency
        readonly property int expireTimeout: 6000
        readonly property bool tracked: root.historyVisible
        readonly property var actions: []

        function dismiss() {
            root.hideHistory()
        }

        function expire() {
            root.hideHistory()
        }
    }

    function hideHistory() {
        historyVisible = false
    }

    function snapshotNotification(notification) {
        history.appName = notification.appName || ""
        history.summary = notification.summary || ""
        history.body = notification.body || ""
        history.appIcon = notification.appIcon || ""
        history.image = notification.image || ""
        history.urgency = notification.urgency
        history.receivedAt = Date.now()
        history.available = true
    }

    NotificationServer {
        id: notificationServer

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        keepOnReload: true

        onNotification: notification => {
            root.hideHistory()
            root.snapshotNotification(notification)
            notification.tracked = true
        }
    }

    IpcHandler {
        target: "notifications"

        function dismissLatest(): bool {
            if (root.historyVisible) {
                root.hideHistory()
                return true
            }

            var notifications = notificationServer.trackedNotifications.values
            if (notifications.length === 0) return false
            notifications[notifications.length - 1].dismiss()
            return true
        }

        function dismissAll(): int {
            var notifications = notificationServer.trackedNotifications.values.slice()
            var dismissed = notifications.length + (root.historyVisible ? 1 : 0)
            root.hideHistory()
            for (var index = notifications.length - 1; index >= 0; index--)
                notifications[index].dismiss()
            return dismissed
        }

        function restoreLatest(): bool {
            if (!history.available) return false
            root.historyVisible = true
            return true
        }

        function count(): int {
            return notificationServer.trackedNotifications.values.length + (root.historyVisible ? 1 : 0)
        }
    }

    PopupWindow {
        id: notificationWindow

        readonly property int stackPadding: 8
        readonly property int maxStackHeight: Math.max(0, (root.hostWindow.screen ? root.hostWindow.screen.height : 0) - root.hostWindow.height - 20)

        anchor.window: root.hostWindow
        anchor.adjustment: PopupAdjustment.Slide
        anchor.rect.x: Math.round(root.hostWindow.width / 2 - width / 2)
        anchor.rect.y: root.hostWindow.height + 10
        implicitWidth: 460
        implicitHeight: Math.min(notificationList.contentHeight, maxStackHeight) + stackPadding * 2
        color: "transparent"
        grabFocus: false
        visible: notificationServer.trackedNotifications.values.length > 0 || root.historyVisible

        ListView {
            id: notificationList

            anchors.top: parent.top
            anchors.topMargin: notificationWindow.stackPadding
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: Math.min(contentHeight, notificationWindow.maxStackHeight)
            spacing: 10
            clip: true
            interactive: contentHeight > height

            model: ScriptModel {
                values: {
                    var notifications = notificationServer.trackedNotifications.values.slice().reverse()
                    if (root.historyVisible && history.available) notifications.unshift(restoredNotification)
                    return notifications
                }
            }

            delegate: NotificationCard {
                required property var modelData

                width: ListView.view.width
                notification: modelData
                theme: root.theme
            }

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 100
                    easing.type: Easing.InCubic
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
