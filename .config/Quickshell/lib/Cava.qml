import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Audio visualiser. Reads cava's raw numeric output and renders one block
// glyph per bar. Level 0 is the resting line, so silence draws a flat baseline
// instead of blank space.
Item {
    id: root

    property color barColor: PywalColors.color4
    property int barSize: Theme.cavaBarSize
    property int barCount: Theme.cavaBarCount
    property int barGap: Theme.cavaBarGap
    property string configPath: "/home/davening/.config/Quickshell/cava.conf"

    // Lets an instance that is normally hidden avoid running cava at all.
    property bool active: true

    // Gate for restarts. Never assign to Process.running directly: doing so
    // would break its binding to `active` and the process would never stop.
    property bool alive: true

    property bool showBackground: true
    property color backgroundColor: Theme.moduleBackground
    property real radius: Theme.pillRadius

    readonly property var levels: ["\u2581", "\u2582", "\u2583", "\u2584", "\u2585", "\u2586", "\u2587", "\u2588"]

    // One glyph per bar. Kept as a single string so each frame is one property
    // assignment, leaving the delegates themselves stable.
    property string frame: ""

    function restingFrame() {
        var out = ""
        for (var i = 0; i < barCount; i++)
            out += levels[0]
        return out
    }

    function frameFromDigits(digits) {
        var out = ""
        for (var i = 0; i < barCount; i++) {
            var level = i < digits.length ? digits.charCodeAt(i) - 48 : 0
            if (isNaN(level) || level < 0)
                level = 0
            out += levels[Math.min(level, levels.length - 1)]
        }
        return out
    }

    implicitWidth: row.implicitWidth + 22
    implicitHeight: Theme.pillHeight

    Component.onCompleted: frame = restingFrame()

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: root.showBackground
        color: root.backgroundColor
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.barGap

        Repeater {
            model: root.barCount

            delegate: Text {
                required property int index

                text: root.frame.charAt(index)
                color: root.barColor
                font.family: Theme.nerdFont
                font.pixelSize: root.barSize
            }
        }
    }

    Process {
        id: cava
        command: ["cava", "-p", root.configPath]
        running: root.active && root.alive

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (data) {
                const digits = data.replace(/\u0000/g, "").trim()
                if (!/^[0-7]+$/.test(digits))
                    return
                root.frame = root.frameFromDigits(digits)
            }
        }

        onExited: {
            root.frame = root.restingFrame()
            // Only respawn when the exit was unexpected, not a deliberate stop.
            if (root.active) {
                root.alive = false
                restartTimer.restart()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 3000
        onTriggered: if (root.active) root.alive = true
    }

    onActiveChanged: {
        if (!root.active)
            root.frame = root.restingFrame()
        else if (!root.alive)
            root.alive = true
    }
}
