import QtQuick
import QtQuick.Layouts
import ".."

// Several modules sharing one pill background, so they read as a single group
// rather than a row of separate pills. Children are placed in the inner
// RowLayout via the default property and are expected to set
// `showBackground: false` so they do not each draw their own pill.
//
// Spacing is 0 because each child keeps its own horizontal padding, which
// provides the gap; the group only adds a little padding at the outer edges.
Rectangle {
    id: root

    default property alias content: row.data

    property int outerPadding: 4
    property int spacing: 0

    implicitWidth: row.implicitWidth + outerPadding * 2
    implicitHeight: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.moduleBackground

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: root.spacing
    }
}
