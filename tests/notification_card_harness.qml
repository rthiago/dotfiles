import QtQuick
import Quickshell
import Quickshell.Io
import "."

ShellRoot {
    id: root

    QtObject {
        id: theme

        readonly property color red: "#f38ba8"
        readonly property color muted: "#a6adc8"
        readonly property color purple: "#cba6f7"
        readonly property color panel: "#2a2b3c"
        readonly property color highlight: "#45475a"
        readonly property color foreground: "#cdd6f4"
        readonly property string fontFamily: "sans-serif"
        readonly property string iconFontFamily: "sans-serif"
        readonly property int fontSizeCaption: 11
        readonly property int fontSizeSmall: 12
        readonly property int fontSizeBody: 13
        readonly property int fontSizeIcon: 17
    }

    Component {
        id: cardComponent

        NotificationCard {
            width: implicitWidth
            height: implicitHeight
            theme: theme
        }
    }

    function notification(actions, appName) {
        return {
            "actions": actions,
            "appIcon": "",
            "appName": appName,
            "body": "Complete",
            "expireTimeout": 6000,
            "image": "",
            "summary": "Check status of running export",
            "tracked": false,
            "urgency": 1,
            "dismiss": function() {},
            "expire": function() {}
        }
    }

    function createCard(actions) {
        return cardComponent.createObject(root, {
            "notification": notification(actions, "Oh My Pi")
        })
    }

    IpcHandler {
        target: "notificationCardTest"

        function run(): bool {
            const noActions = root.createCard([])
            const emptyAction = root.createCard([{
                "text": "   ",
                "invoke": function() {}
            }])
            const labeledAction = root.createCard([{
                "text": "Open",
                "invoke": function() {}
            }])

            const passed = noActions !== null
                && emptyAction !== null
                && labeledAction !== null
                && noActions.usesFallbackIcon
                && noActions.fallbackText === "O"
                && !emptyAction.hasVisibleActions
                && emptyAction.implicitHeight === noActions.implicitHeight
                && labeledAction.hasVisibleActions
                && labeledAction.implicitHeight > noActions.implicitHeight

            labeledAction.destroy()
            emptyAction.destroy()
            noActions.destroy()
            return passed
        }
    }
}
