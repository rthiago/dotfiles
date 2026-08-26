import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var hostWindow
    required property var theme
    property var usage: ({})
    property string providerId: ""
    property color accent: theme.purple
    property real anchorCenter: 0
    readonly property var metrics: usage && usage.metrics ? usage.metrics : []
    readonly property var blocks: {
        const result = []
        const sections = usage && usage.sections ? usage.sections : []
        for (let index = 0; index < sections.length; index++) {
            if (sections[index].type === "block") result.push(sections[index])
        }
        return result
    }
    readonly property bool hasError: Boolean(usage && (usage.status === "error" || usage.error))
    readonly property bool loading: !usage || usage.status === "loading"
    readonly property color statusColor: hasError
        ? theme.red
        : loading || usage.stale
            ? theme.yellow
            : theme.green
    readonly property string providerName: usage && usage.display_name
        ? usage.display_name
        : providerId === "anthropic" ? "Claude" : "Codex"
    readonly property string planName: usage && usage.plan ? usage.plan : "Usage overview"
    readonly property string updatedText: {
        if (!usage || !usage.fetched_at)
            return hasError ? "Unavailable" : "Waiting for usage data"
        const updated = new Date(usage.fetched_at)
        return isNaN(updated.getTime()) ? "Recently updated" : "Updated " + Qt.formatDateTime(updated, "HH:mm")
    }

    anchor.window: hostWindow
    anchor.adjustment: PopupAdjustment.Slide
    anchor.rect.x: Math.round(Math.max(10, Math.min(hostWindow.width - width - 10, anchorCenter - width / 2)))
    anchor.rect.y: hostWindow.height + 8
    implicitWidth: 400
    implicitHeight: Math.min(460, Math.max(176, contentColumn.implicitHeight + 106))
    color: "transparent"
    grabFocus: true
    visible: false

    function progressColor(percent) {
        const value = Number(percent) || 0
        if (value > 80) return theme.red
        return theme.green
    }

    function detailPart(detail, index) {
        const parts = String(detail || "").split("·")
        return parts.length > index ? parts[index].trim() : ""
    }

    function detailRemainder(detail) {
        const parts = String(detail || "").split("·")
        return parts.length > 1 ? parts.slice(1).join(" · ").trim() : ""
    }

    function toggleFor(item, provider, data, color) {
        const point = item.mapToItem(hostWindow.contentItem, item.width / 2, 0)
        const sameProvider = root.providerId === provider && root.visible
        root.anchorCenter = point.x
        root.providerId = provider
        root.usage = data || ({})
        root.accent = color
        root.visible = !sameProvider
        if (root.visible) keyScope.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.theme.panel
        border.width: 1
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)

        Item {
            id: popupHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.top: parent.top
            anchors.topMargin: 18
            height: 44

            Rectangle {
                id: providerIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 34
                radius: 10
                color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)

                Text {
                    anchors.centerIn: parent
                    text: root.providerId === "anthropic" ? "󰜡" : "󰬫"
                    color: root.accent
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.fontSizeIcon
                    renderType: Text.NativeRendering
                }
            }

            Rectangle {
                id: statusBadge
                width: statusLabel.implicitWidth + 18
                height: 24
                radius: 8
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.13)

                Text {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: root.hasError ? "Error" : root.loading ? "Loading" : root.usage.stale ? "Stale" : "Live"
                    color: root.statusColor
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeCaption
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }
            }

            Column {
                anchors.left: providerIcon.right
                anchors.leftMargin: 12
                anchors.right: statusBadge.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    width: parent.width
                    text: root.providerName + " usage"
                    color: root.theme.foreground
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeTitle
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }

                Text {
                    width: parent.width
                    text: root.planName
                    color: root.theme.muted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSmall
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }
            }
        }

        Rectangle {
            id: headerDivider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.top: popupHeader.bottom
            anchors.topMargin: 12
            height: 1
            color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.7)
        }

        Flickable {
            id: contentViewport
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: headerDivider.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.topMargin: 12
            anchors.bottomMargin: 18
            contentWidth: width
            contentHeight: contentColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentColumn
                width: parent.width
                spacing: 12

                Rectangle {
                    visible: root.hasError
                    width: parent.width
                    height: visible ? errorText.implicitHeight + 24 : 0
                    radius: 10
                    color: Qt.rgba(root.theme.red.r, root.theme.red.g, root.theme.red.b, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(root.theme.red.r, root.theme.red.g, root.theme.red.b, 0.28)

                    Text {
                        id: errorText
                        anchors.fill: parent
                        anchors.margins: 12
                        text: root.usage && root.usage.error ? root.usage.error : "Usage data is unavailable"
                        color: root.theme.red
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSmall
                        wrapMode: Text.Wrap
                        renderType: Text.NativeRendering
                    }
                }

                Repeater {
                    model: root.metrics

                    Column {
                        id: metric
                        required property var modelData
                        width: contentColumn.width
                        spacing: 7

                        Item {
                            width: parent.width
                            height: 20

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: metric.modelData.label || "Usage"
                                color: root.theme.foreground
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBody
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: metric.modelData.value || Math.round(Number(metric.modelData.percent) || 0) + "%"
                                color: root.progressColor(metric.modelData.percent)
                                font.family: root.theme.monoFontFamily
                                font.pixelSize: root.theme.fontSizeBody
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }
                        }

                        Rectangle {
                            id: metricTrack
                            width: parent.width
                            height: 8
                            radius: 4
                            color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.58)

                            Rectangle {
                                width: metricTrack.width * Math.max(0, Math.min(100, Number(metric.modelData.percent) || 0)) / 100
                                height: parent.height
                                radius: parent.radius
                                color: root.progressColor(metric.modelData.percent)

                                Behavior on width {
                                    NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 17

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.detailPart(metric.modelData.detail, 0)
                                color: root.theme.muted
                                font.family: root.theme.monoFontFamily
                                font.pixelSize: root.theme.fontSizeCaption
                                renderType: Text.NativeRendering
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.detailRemainder(metric.modelData.detail)
                                color: root.theme.muted
                                font.family: root.theme.monoFontFamily
                                font.pixelSize: root.theme.fontSizeCaption
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }

                Repeater {
                    model: root.blocks

                    Rectangle {
                        id: detailBlock
                        required property var modelData
                        width: contentColumn.width
                        height: blockContent.implicitHeight + 24
                        radius: 10
                        color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.34)

                        Column {
                            id: blockContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 5

                            Text {
                                text: detailBlock.modelData.label || "Details"
                                color: root.theme.foreground
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSmall
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }

                            Repeater {
                                model: detailBlock.modelData.body || []

                                Text {
                                    required property var modelData
                                    width: blockContent.width
                                    text: modelData
                                    color: root.theme.muted
                                    font.family: root.theme.monoFontFamily
                                    font.pixelSize: root.theme.fontSizeCaption
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: !root.hasError && root.metrics.length === 0 && root.blocks.length === 0
                    width: parent.width
                    text: "Waiting for usage data"
                    color: root.theme.muted
                    horizontalAlignment: Text.AlignHCenter
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSmall
                    renderType: Text.NativeRendering
                }

                Text {
                    width: parent.width
                    text: "󰅐  " + root.updatedText
                    color: root.theme.muted
                    opacity: 0.8
                    horizontalAlignment: Text.AlignRight
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.fontSizeLabel
                    renderType: Text.NativeRendering
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
