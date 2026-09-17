import QtQuick
import Quickshell.Io
import ".."
import "../lib"

// Default audio sink volume. Click toggles mute.
Item {
    id: root

    // Set false when this sits inside a shared group pill.
    property bool showBackground: true

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property int percent: 0
    property bool muted: false

    function icon() {
        if (muted)
            return "volume_off"
        if (percent < 34)
            return "volume_mute"
        if (percent < 67)
            return "volume_down"
        return "volume_up"
    }

    function label() {
        return muted ? "muted" : percent + "%"
    }

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/vol.sh"
        interval: 1000
        onValueChanged: {
            const parts = value.split("|")
            root.percent = parseInt(parts[0], 10) || 0
            root.muted = parts[1] === "1"
        }
    }

    Process {
        id: toggleMute
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }

    Pill {
        id: pill
        anchors.fill: parent
        showBackground: root.showBackground
        icon: root.icon()
        label: root.label()
        iconColor: PywalColors.color4
        tooltip: root.muted ? "Muted" : "Volume: " + root.percent + "%"
        onClicked: toggleMute.running = true
    }
}
