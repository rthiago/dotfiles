import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

Rectangle {
    id: root

    required property var notification
    required property var theme

    readonly property color accentColor: notification.urgency === NotificationUrgency.Critical
        ? theme.red
        : notification.urgency === NotificationUrgency.Low
            ? theme.muted
            : theme.purple
    readonly property string requestedIcon: notification.image || notification.appIcon || ""
    readonly property string iconSource: {
        if (!requestedIcon) return ""
        if (requestedIcon.startsWith("/") || requestedIcon.includes(":")) return requestedIcon
        return Quickshell.iconPath(requestedIcon, true)
    }
    readonly property int timeoutMs: notification.expireTimeout > 0
        ? Math.round(notification.expireTimeout)
        : 6000

    implicitWidth: 460
    implicitHeight: content.implicitHeight + 28
    radius: 14
    color: theme.panel
    border.width: 1
    border.color: Qt.rgba(theme.highlight.r, theme.highlight.g, theme.highlight.b, 0.9)
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 4
        color: root.accentColor
    }

    Column {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 10

        Item {
            width: parent.width
            height: Math.max(40, heading.implicitHeight)

            Rectangle {
                id: iconTile

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                radius: 11
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16)

                IconImage {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    source: root.iconSource
                    visible: root.iconSource !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.iconSource === ""
                    text: root.notification.urgency === NotificationUrgency.Critical ? "" : ""
                    color: root.accentColor
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.fontSizeIcon
                }
            }

            Column {
                id: heading

                anchors.left: iconTile.right
                anchors.right: closeButton.left
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: root.notification.appName || "Notification"
                    color: root.theme.muted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeCaption
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.notification.summary || root.notification.appName || "Notification"
                    color: root.theme.foreground
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBody
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                id: closeButton

                anchors.right: parent.right
                anchors.top: parent.top
                width: 28
                height: 28
                radius: 9
                color: closeMouse.containsMouse ? root.theme.highlight : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeMouse.containsMouse ? root.theme.foreground : root.theme.muted
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.fontSizeSmall
                }

                MouseArea {
                    id: closeMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notification.dismiss()
                }
            }
        }

        Text {
            id: bodyText

            visible: text.length > 0
            width: parent.width
            text: root.notification.body || ""
            textFormat: Text.PlainText
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeSmall
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
        }

        Flow {
            id: actions

            visible: root.notification.actions.length > 0
            width: parent.width
            height: visible ? childrenRect.height : 0
            spacing: 8

            Repeater {
                model: root.notification.actions

                delegate: Rectangle {
                    id: actionButton

                    required property var modelData

                    width: actionLabel.implicitWidth + 20
                    height: 28
                    radius: 9
                    color: actionMouse.containsMouse ? root.theme.highlight : Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.55)
                    border.width: 1
                    border.color: Qt.rgba(root.theme.purple.r, root.theme.purple.g, root.theme.purple.b, 0.45)

                    Text {
                        id: actionLabel

                        anchors.centerIn: parent
                        text: actionButton.modelData.text
                        color: root.theme.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeCaption
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: actionMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: actionButton.modelData.invoke()
                    }
                }
            }
        }
    }

    Timer {
        interval: root.timeoutMs
        running: root.notification.tracked
            && root.notification.expireTimeout !== 0
            && root.notification.urgency !== NotificationUrgency.Critical
        repeat: false
        onTriggered: root.notification.expire()
    }
}
