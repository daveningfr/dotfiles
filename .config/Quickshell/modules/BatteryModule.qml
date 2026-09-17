import QtQuick
import Quickshell.Io
import ".."
import "../lib"

// Battery level with charging indication. Owns the one-shot full/low
// notifications so they fire once per cycle rather than on every poll.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property int percent: 0
    property string status: "unknown"

    readonly property bool charging: status === "Charging"

    function icon() {
        if (charging)
            return "󰚥" // power plug
        if (percent < 30)
            return "󱊡" // battery low
        if (percent < 60)
            return "󱊢" // battery medium
        return "󱊣"     // battery high
    }

    function color() {
        if (charging)
            return PywalColors.color2
        if (percent < 15)
            return PywalColors.color1
        if (percent < 30)
            return PywalColors.color3
        return PywalColors.color6
    }

    onPercentChanged: {
        if (percent >= 100 && (status === "Charging" || status === "Full"))
            fullNotify.running = true
        else if (percent <= 15 && status !== "Charging" && status !== "Full")
            criticalNotify.running = true
    }

    onStatusChanged: {
        if (status === "Full")
            fullNotify.running = true
    }

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/bat.sh"
        interval: 10000
        onValueChanged: {
            const parts = value.split("|")
            root.percent = parseInt(parts[0], 10) || 0
            root.status = parts[1] || "unknown"
        }
    }

    Process {
        id: fullNotify
        command: ["/home/davening/.config/Quickshell/scripts/battery-notify.sh", "full"]
    }

    Process {
        id: criticalNotify
        command: ["/home/davening/.config/Quickshell/scripts/battery-notify.sh", "critical"]
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: root.icon()
        iconFont: Theme.nerdFont
        label: root.percent + "%"
        iconColor: root.color()
        labelColor: root.color()
        tooltip: "Battery: " + root.percent + "% (" + root.status + ")"
    }
}
