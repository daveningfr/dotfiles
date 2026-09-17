import QtQuick
import QtQuick.Layouts
import ".."

// Generic bar pill: an optional icon plus a label, with hover highlight,
// tooltip, click/scroll signals. Every bar module is built from this.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""

    property string iconFont: Theme.symbolFont
    property string labelFont: Theme.nerdFont

    property color iconColor: PywalColors.color4
    property color labelColor: PywalColors.foreground

    property bool showBackground: true
    property bool highlightOnHover: true
    property color backgroundColor: Theme.moduleBackground
    property color hoverColor: Theme.hoverWash
    property real radius: Theme.pillRadius

    property int hPadding: 12
    property int contentSpacing: 7
    property int iconSize: 15
    property int labelSize: 13
    property int maxLabelWidth: 400

    property string tooltip: ""

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrollUp()
    signal scrollDown()
    signal entered()
    signal exited()

    implicitWidth: content.implicitWidth + hPadding * 2
    implicitHeight: Theme.pillHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: root.showBackground
        color: (root.highlightOnHover && mouse.containsMouse) ? root.hoverColor : root.backgroundColor
    }

    // Used by modules that sit inside a shared container instead of drawing
    // their own pill: still give hover feedback, but no background.
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: !root.showBackground && root.highlightOnHover && mouse.containsMouse
        color: root.hoverColor
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: root.contentSpacing

        Text {
            text: root.icon
            color: root.iconColor
            font.family: root.iconFont
            font.pixelSize: root.iconSize
            visible: root.icon !== ""
        }

        Text {
            text: root.label
            color: root.labelColor
            font.family: root.labelFont
            font.pixelSize: root.labelSize
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label !== ""
        }
    }

    // Remembers which text this pill published, so a later tooltip from a
    // different module is not cleared by this one's hide().
    property string publishedTooltip: ""

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (event) {
            if (event.button === Qt.LeftButton)
                root.clicked()
            else if (event.button === Qt.RightButton)
                root.rightClicked()
            else
                root.middleClicked()
        }

        onWheel: function (wheel) {
            if (wheel.angleDelta.y > 0)
                root.scrollUp()
            else
                root.scrollDown()
        }

        onEntered: {
            if (root.tooltip !== "") {
                root.publishedTooltip = root.tooltip
                Tooltip.show(root.tooltip, root.mapToItem(null, root.width / 2, 0).x)
            }
            root.entered()
        }

        onExited: {
            Tooltip.hide(root.publishedTooltip)
            root.publishedTooltip = ""
            root.exited()
        }
    }
}
