import QtQuick
import ".."
import "../lib"

// Processor usage, sampled by scripts/cpu.sh.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property int usage: 0

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/cpu.sh"
        interval: 2000
        onValueChanged: root.usage = parseInt(value, 10) || 0
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: "memory"
        label: root.usage + "%"
        iconColor: PywalColors.color2
        tooltip: "CPU usage: " + root.usage + "%"
    }
}
