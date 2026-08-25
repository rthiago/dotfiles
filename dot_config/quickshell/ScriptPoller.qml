import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property var command: []
    property int interval: 30000
    property string output: ""
    property bool pending: false

    signal updated(string output)

    function refresh() {
        if (process.running) {
            pending = true
            return
        }
        process.running = true
    }

    Component.onCompleted: refresh()

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: process
        command: root.command

        stdout: StdioCollector {
            onStreamFinished: {
                root.output = text.trim()
                root.updated(root.output)
            }
        }

        onExited: {
            if (root.pending) {
                root.pending = false
                root.refresh()
            }
        }
    }
}
