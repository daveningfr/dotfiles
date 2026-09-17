import QtQuick
import ".."
import "../lib"

// Bar clock. Click toggles a longer date/time label.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.pillHeight

    property bool alternate: false
    property string timeText: Qt.formatDateTime(new Date(), "HH:mm")
    property string detailText: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy\nHH:mm:ss")

    function label() {
        return alternate
            ? Qt.formatDateTime(new Date(), "ddd, dd MMM  HH:mm")
            : timeText
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.timeText = Qt.formatDateTime(new Date(), "HH:mm")
            root.detailText = Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy\nHH:mm:ss")
        }
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon: ""
        label: root.label()
        labelColor: PywalColors.foreground
        tooltip: root.detailText
        onClicked: root.alternate = !root.alternate
    }
}
