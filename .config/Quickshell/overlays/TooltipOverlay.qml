import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// Renders the single shared tooltip published through the Tooltip singleton.
// Lives on the overlay layer so it is never clipped by the bar's surface.
PanelWindow {
    id: root

    visible: Tooltip.text !== ""

    anchors {
        top: true
        left: true
    }
    margins {
        // The bar's exclusive zone already offsets this surface, so keep this
        // small.
        top: 4
        left: Math.max(6, Tooltip.screenX - implicitWidth / 2)
    }

    implicitWidth: box.implicitWidth
    implicitHeight: box.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.focusable: false

    Rectangle {
        id: box
        anchors.fill: parent
        implicitWidth: label.implicitWidth + 22
        implicitHeight: label.implicitHeight + 16
        radius: 8
        color: Theme.cardBackground
        border.color: Theme.cardBorder
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent
            text: Tooltip.text
            color: PywalColors.foreground
            font.family: Theme.nerdFont
            font.pixelSize: 12
            lineHeight: 1.2
        }
    }
}
