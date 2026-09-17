import QtQuick
import ".."
import "../lib"

// Package temperature. Turns red at 80C to match the previous warning state.
Item {
    id: root

    // Set false when this sits inside a shared group pill.
    property bool showBackground: true

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property int celsius: 0
    readonly property bool critical: celsius >= 80

    Poller {
        command: "/home/davening/.config/Quickshell/scripts/temp.sh"
        interval: 5000
        onValueChanged: root.celsius = parseInt(value, 10) || 0
    }

    Pill {
        id: pill
        anchors.fill: parent
        showBackground: root.showBackground
        icon: "device_thermostat"
        label: root.celsius + "\u00B0C"
        iconColor: root.critical ? PywalColors.color1 : PywalColors.color3
        tooltip: "Temperature: " + root.celsius + "\u00B0C"
    }
}
