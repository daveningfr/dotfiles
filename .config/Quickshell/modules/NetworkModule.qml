import QtQuick
import ".."
import "../lib"

// Active network connection. Uses a Nerd Font glyph for ethernet because the
// Material set has no ligature for it.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property string kind: "none"
    property string name: "disconnected"

    function icon() {
        if (kind === "wifi")
            return "wifi"
        if (kind === "ethernet")
            return "󰈀"
        return "wifi_off"
    }

    function iconFont() {
        return kind === "ethernet" ? Theme.nerdFont : Theme.symbolFont
    }

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/net.sh"
        interval: 5000
        onValueChanged: {
            const parts = value.split("|")
            root.kind = parts[0] || "none"
            root.name = parts[1] || "disconnected"
        }
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: root.icon()
        iconFont: root.iconFont()
        label: root.name
        iconColor: PywalColors.color5
        tooltip: root.kind + ": " + root.name
    }
}
