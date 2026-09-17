import QtQuick
import Quickshell.Io
import ".."
import "../lib"

// swaync notification count and Do Not Disturb state.
// Left click opens the panel, right click toggles DND.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property bool dnd: false
    property int count: 0

    function icon() {
        if (dnd)
            return "do_not_disturb_on"
        return count > 0 ? "notifications_active" : "notifications"
    }

    function label() {
        return count > 0 ? String(count) : ""
    }

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/nc.sh"
        interval: 2000
        onValueChanged: {
            const parts = value.split("|")
            root.dnd = parts[0] === "true"
            root.count = parseInt(parts[1], 10) || 0
        }
    }

    Process {
        id: togglePanel
        command: ["swaync-client", "-t", "-sw"]
    }

    Process {
        id: toggleDnd
        command: ["swaync-client", "-d", "-sw"]
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: root.icon()
        label: root.label()
        iconColor: PywalColors.color4
        tooltip: root.dnd ? "Do Not Disturb" : "Notifications: " + root.count
        onClicked: togglePanel.running = true
        onRightClicked: toggleDnd.running = true
    }
}
