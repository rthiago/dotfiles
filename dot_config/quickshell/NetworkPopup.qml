import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var hostWindow
    required property var theme
    required property var services
    property real anchorCenter: 0

    readonly property int profileCount: services.wireguardProfiles ? services.wireguardProfiles.length : 0
    readonly property color networkAccent: services.wireguardConnected
        ? theme.yellow
        : services.networkConnected
            ? theme.green
            : theme.red

    anchor.window: hostWindow
    anchor.adjustment: PopupAdjustment.Slide
    anchor.rect.x: Math.round(Math.max(10, Math.min(hostWindow.width - width - 10, anchorCenter - width / 2)))
    anchor.rect.y: hostWindow.height + 8
    implicitWidth: 390
    implicitHeight: 185 + Math.max(1, profileCount) * 52 + (services.wireguardError ? 38 : 0)
    color: "transparent"
    grabFocus: true
    visible: false

    function toggleFor(item) {
        const point = item.mapToItem(hostWindow.contentItem, item.width / 2, 0)
        root.anchorCenter = point.x
        root.visible = !root.visible
        if (root.visible) keyScope.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.theme.panel
        border.width: 1
        border.color: Qt.rgba(root.networkAccent.r, root.networkAccent.g, root.networkAccent.b, 0.5)

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Item {
                width: parent.width
                height: 44

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 34
                    height: 34
                    radius: 10
                    color: Qt.rgba(
                        root.networkAccent.r,
                        root.networkAccent.g,
                        root.networkAccent.b,
                        0.16
                    )

                    Text {
                        anchors.centerIn: parent
                        text: root.services.networkIcon || "󰖪"
                        color: root.networkAccent
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.fontSizeIcon
                        renderType: Text.NativeRendering
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 46
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: "Network"
                        color: root.theme.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeTitle
                        font.weight: Font.DemiBold
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: root.services.networkConnected
                            ? root.services.networkConnection
                            : "Disconnected"
                        color: root.theme.muted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSmall
                        elide: Text.ElideRight
                        renderType: Text.NativeRendering
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.7)
            }

            Text {
                text: "WIREGUARD"
                color: root.theme.muted
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLabel
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
                renderType: Text.NativeRendering
            }

            Item {
                width: parent.width
                height: root.profileCount > 0 ? root.profileCount * 52 - 6 : 46

                Text {
                    visible: root.profileCount === 0
                    anchors.centerIn: parent
                    text: "No WireGuard profiles configured"
                    color: root.theme.muted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSmall
                    renderType: Text.NativeRendering
                }

                Column {
                    visible: root.profileCount > 0
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: root.services.wireguardProfiles || []

                        Rectangle {
                            id: profileRow
                            required property var modelData

                            readonly property bool pending: root.services.pendingWireguardUuid === modelData.uuid

                            width: parent.width
                            height: 46
                            radius: 10
                            color: profilePointer.containsMouse
                                ? root.theme.highlight
                                : Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.28)
                            border.width: modelData.active ? 1 : 0
                            border.color: Qt.rgba(root.theme.green.r, root.theme.green.g, root.theme.green.b, 0.55)

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.right: toggle.left
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: profileRow.modelData.name
                                    color: root.theme.foreground
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeBody
                                    font.bold: profileRow.modelData.active
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: profileRow.pending
                                        ? "UPDATING"
                                        : profileRow.modelData.active
                                            ? "CONNECTED"
                                            : "DISCONNECTED"
                                    color: profileRow.pending
                                        ? root.theme.yellow
                                        : profileRow.modelData.active
                                            ? root.theme.green
                                            : root.theme.muted
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeLabel
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 0.8
                                    renderType: Text.NativeRendering
                                }
                            }

                            Rectangle {
                                id: toggle
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                width: 38
                                height: 22
                                radius: 11
                                color: profileRow.modelData.active ? root.theme.green : root.theme.highlight
                                opacity: profileRow.pending ? 0.55 : 1

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    y: 3
                                    x: profileRow.modelData.active ? parent.width - width - 3 : 3
                                    color: profileRow.modelData.active ? root.theme.background : root.theme.muted

                                    Behavior on x {
                                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }
                                }
                            }

                            MouseArea {
                                id: profilePointer
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !profileRow.pending && !root.services.pendingWireguardUuid
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.services.toggleWireguard(
                                    profileRow.modelData.uuid,
                                    profileRow.modelData.active
                                )
                            }
                        }
                    }
                }
            }

            Text {
                visible: !!root.services.wireguardError
                width: parent.width
                height: visible ? 26 : 0
                text: root.services.wireguardError
                color: root.theme.red
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeCaption
                wrapMode: Text.Wrap
                renderType: Text.NativeRendering
            }

            Rectangle {
                width: parent.width
                height: 38
                radius: 10
                color: settingsPointer.containsMouse ? root.theme.highlight : "transparent"
                border.width: 1
                border.color: root.theme.highlight

                Text {
                    anchors.centerIn: parent
                    text: "󰒓  Open Network Settings"
                    color: root.theme.foreground
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: settingsPointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.visible = false
                        Quickshell.execDetached({ command: ["nm-connection-editor"] })
                    }
                }
            }
        }
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        Keys.onEscapePressed: root.visible = false
    }
}
