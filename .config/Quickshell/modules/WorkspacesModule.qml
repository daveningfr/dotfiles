import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

// Shows only the focused Hyprland workspace. When it changes, the new number
// swipes in from the side the change came from: increasing ids travel left,
// decreasing ones travel right.
Rectangle {
    id: root

    property int swipeDuration: 130

    readonly property int activeId: Hyprland.focusedWorkspace !== null
                                     ? Hyprland.focusedWorkspace.id
                                     : 0

    // The number currently painted, the number being animated toward, and the
    // horizontal offset that drives the swipe.
    property int displayId: activeId
    property int pendingId: activeId
    property real offset: 0

    implicitWidth: sizer.implicitWidth + 24
    implicitHeight: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.moduleBackground

    // Sized to the number actually shown (or about to be shown) so the padding
    // stays tight and symmetric instead of reserving room for two digits.
    Text {
        id: sizer
        visible: false
        text: String(Math.max(root.displayId, root.pendingId))
        font.family: Theme.nerdFont
        font.pixelSize: 13
        font.bold: true
    }

    Item {
        id: viewport
        anchors.centerIn: parent
        width: root.width - 24
        height: parent.height
        clip: true

        Text {
            x: root.offset
            width: viewport.width
            anchors.verticalCenter: parent.verticalCenter
            text: root.displayId
            color: PywalColors.color12
            font.family: Theme.nerdFont
            font.pixelSize: 13
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    onActiveIdChanged: {
        if (activeId === displayId)
            return
        pendingId = activeId
        swipe.direction = activeId > displayId ? 1 : -1
        swipe.restart()
    }

    SequentialAnimation {
        id: swipe
        property real direction: 1

        // Old number leaves toward the side the change moves away from.
        NumberAnimation {
            target: root
            property: "offset"
            to: -swipe.direction * viewport.width
            duration: root.swipeDuration
            easing.type: Easing.OutCubic
        }
        // Jump to the opposite edge, swap the number, then slide it into place.
        PropertyAction {
            target: root
            property: "offset"
            value: swipe.direction * viewport.width
        }
        ScriptAction {
            script: root.displayId = root.pendingId
        }
        NumberAnimation {
            target: root
            property: "offset"
            to: 0
            duration: root.swipeDuration
            easing.type: Easing.OutCubic
        }
    }
}
