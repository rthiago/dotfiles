import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var hostWindow
    required property var theme
    property string heading: ""
    property string body: ""
    property color accent: theme.purple
    property real anchorCenter: 0

    anchor.window: hostWindow
    anchor.rect.x: Math.round(Math.max(10, Math.min(hostWindow.width - width - 10, anchorCenter - width / 2)))
    anchor.rect.y: hostWindow.height + 8
    implicitWidth: 430
    implicitHeight: Math.min(380, Math.max(118, bodyText.implicitHeight + 82))
    color: "transparent"
    grabFocus: true
    visible: false

    function toggleFor(item, title, content, color) {
        const point = item.mapToItem(hostWindow.contentItem, item.width / 2, 0)
        const sameContent = root.heading === title && root.visible
        root.anchorCenter = point.x
        root.heading = title
        root.body = content || "No details available"
        root.accent = color
        root.visible = !sameContent
        if (root.visible) keyScope.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.theme.panel
        border.width: 1
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)

        Rectangle {
            width: 4
            height: 30
            radius: 2
            color: root.accent
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.top: parent.top
            anchors.topMargin: 18
        }

        Text {
            id: headingText
            anchors.left: parent.left
            anchors.leftMargin: 34
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 18
            text: root.heading
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 15
            font.bold: true
            renderType: Text.NativeRendering
        }

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: headingText.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 20
            anchors.topMargin: 14
            contentWidth: width
            contentHeight: bodyText.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Text {
                id: bodyText
                width: parent.width
                text: root.body
                color: root.theme.foreground
                opacity: 0.9
                font.family: root.theme.fontFamily
                font.pixelSize: 13
                lineHeight: 1.22
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
            }
        }
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        Keys.onEscapePressed: root.visible = false
    }
}
