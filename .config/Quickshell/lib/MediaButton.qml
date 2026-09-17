import QtQuick
import ".."

// Transport button used inside the media island.
Rectangle {
    id: root

    property string glyph: ""
    property bool emphasised: false
    signal activated()

    implicitWidth: emphasised ? 34 : 30
    implicitHeight: 26
    radius: 7
    color: mouse.pressed
        ? Qt.rgba(PywalColors.color12.r, PywalColors.color12.g, PywalColors.color12.b, 0.5)
        : Qt.rgba(PywalColors.color8.r, PywalColors.color8.g, PywalColors.color8.b, 0.3)

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.emphasised ? PywalColors.color13 : PywalColors.foreground
        font.family: Theme.symbolFont
        font.pixelSize: root.emphasised ? 18 : 16
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        // Hover stays with the surrounding area so the island does not
        // collapse; pressed feedback is enough here.
        hoverEnabled: false
        onClicked: root.activated()
    }
}
