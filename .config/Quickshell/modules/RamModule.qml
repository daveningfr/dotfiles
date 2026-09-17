import QtQuick
import ".."
import "../lib"

// Memory usage, sampled by scripts/ram.sh.
Item {
    id: root

    // Set false when this sits inside a shared group pill.
    property bool showBackground: true

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property int usage: 0

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/ram.sh"
        interval: 2000
        onValueChanged: root.usage = parseInt(value, 10) || 0
    }

    Pill {
        id: pill
        anchors.fill: parent
        showBackground: root.showBackground
        icon: "memory"
        label: root.usage + "%"
        iconColor: PywalColors.color6
        tooltip: "Memory usage: " + root.usage + "%"
    }
}
