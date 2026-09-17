import QtQuick
import ".."
import "../lib"

// Bluetooth power state, with a connected-device count when present.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property bool powered: false
    property int connected: 0
    property string deviceName: ""

    function icon() {
        if (!powered)
            return "bluetooth_disabled"
        return connected > 0 ? "bluetooth_connected" : "bluetooth"
    }

    function label() {
        return connected > 0 ? String(connected) : ""
    }

    function tooltipText() {
        if (!powered)
            return "Bluetooth off"
        if (connected > 0)
            return connected + " connected\n" + deviceName
        return "Bluetooth on"
    }

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/bt.sh"
        interval: 5000
        onValueChanged: {
            const parts = value.split("|")
            root.powered = parts[0] === "on"
            root.connected = parseInt(parts[1], 10) || 0
            root.deviceName = parts[2] || ""
        }
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: root.icon()
        label: root.label()
        iconColor: PywalColors.color7
        tooltip: root.tooltipText()
    }
}
