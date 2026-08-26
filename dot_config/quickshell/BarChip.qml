import QtQuick

Rectangle {
    id: root

    required property var theme
    property string text: ""
    property color accent: theme.foreground
    property bool selected: false
    property bool compact: false

    signal clicked(int button)
    signal wheel(int delta)

    implicitWidth: Math.max(compact ? 30 : 36, label.implicitWidth + (compact ? 14 : 20))
    implicitHeight: 28
    radius: 9
    color: selected
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.18)
        : pointer.containsMouse
            ? Qt.rgba(theme.highlight.r, theme.highlight.g, theme.highlight.b, 0.7)
            : Qt.rgba(theme.highlight.r, theme.highlight.g, theme.highlight.b, 0.24)
    border.width: selected ? 1 : 0
    border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.55)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.accent
        font.family: root.theme.iconFontFamily
        font.pixelSize: root.theme.fontSizeBar
        font.weight: Font.Medium
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => root.clicked(mouse.button)
        onWheel: wheel => root.wheel(wheel.angleDelta.y)
    }
}
