import QtQuick
import ".."

// Horizontal ticker for text that does not fit. When the string is wider than
// the available space it slides continuously and loops seamlessly; when it
// fits, it sits still, left-aligned.
Item {
    id: root

    property string text: ""
    property string fontFamily: Theme.nerdFont
    property int pixelSize: 13
    property bool bold: false
    property color color: "white"

    // Blank space between the end of one pass and the start of the next.
    property int gap: 44
    // Pixels travelled per second.
    property real speed: 34
    // Cap used for the implicit width so a long string cannot stretch the bar.
    property int maxWidth: 200

    // Always measured from the full string so the probe stays accurate while
    // the visible copies scroll.
    readonly property real naturalWidth: measure.implicitWidth
    readonly property bool scrolls: width > 0 && naturalWidth > width

    implicitWidth: Math.min(naturalWidth, maxWidth)
    implicitHeight: Math.ceil(measure.implicitHeight)
    clip: true

    Text {
        id: measure
        visible: false
        text: root.text
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }

    Row {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.gap

        Text {
            text: root.text
            color: root.color
            font.family: root.fontFamily
            font.pixelSize: root.pixelSize
            font.bold: root.bold
        }

        // Second copy closes the loop, so the slide never shows a gap.
        Text {
            text: root.text
            color: root.color
            font.family: root.fontFamily
            font.pixelSize: root.pixelSize
            font.bold: root.bold
            visible: root.scrolls
        }
    }

    NumberAnimation {
        id: scroll
        target: track
        property: "x"
        from: 0
        to: -(root.naturalWidth + root.gap)
        duration: Math.max(1600, (root.naturalWidth + root.gap) / Math.max(1, root.speed) * 1000)
        loops: Animation.Infinite
        running: root.scrolls
    }

    onTextChanged: reset()
    onWidthChanged: reset()
    Component.onCompleted: reset()

    function reset() {
        scroll.stop()
        track.x = 0
        if (scrolls)
            scroll.restart()
    }
}
