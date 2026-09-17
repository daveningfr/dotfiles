import QtQuick
import Quickshell
import Quickshell.Io

// Runs a command on an interval and exposes its trimmed stdout as `value`.
Scope {
    id: root

    property string command: ""
    property int interval: 3000
    property string value: ""

    Process {
        id: process
        command: ["sh", "-c", root.command]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.value = this.text.trim()
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: process.running = true
    }
}
