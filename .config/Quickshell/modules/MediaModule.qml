import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../lib"

// Now-playing module. The bar shows a compact pill; hovering it floats a
// separate overlay surface (the "island") that grows outward in both
// directions from the pill's centre and shows full track details.
Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    // ------------------------------------------------------------------
    // Player state
    // ------------------------------------------------------------------
    property string status: "Stopped"
    property string artist: ""
    property string title: ""
    property string album: ""
    property string art: ""
    // MPRIS name of the player, e.g. "spotify" or "firefox.instance_1_2".
    property string player: ""
    property real progress: 0
    property string positionText: "0:00"
    property string durationText: "0:00"

    // ------------------------------------------------------------------
    // Island state
    // ------------------------------------------------------------------
    property bool pillHovered: false
    property bool islandHovered: false
    property bool islandVisible: false
    property real islandCenterX: 405
    property real islandExpansion: 0

    readonly property real islandCollapsedWidth: pill.width
    readonly property real islandExpandedWidth: 470
    readonly property real islandCollapsedHeight: 32
    // Tall enough for title, album, artist, progress, times and the controls.
    readonly property real islandExpandedHeight: 172

    function label() {
        if (status === "Stopped" || title === "")
            return "Nothing Playing"
        return artist !== "" ? artist + " \u2014 " + title : title
    }

    // Which app is playing, rather than what it is playing. Shown in the bar
    // and the island's collapsed header so those two stay identical, leaving
    // the track details to the expanded card.
    function sourceLabel() {
        if (player === "")
            return "Nothing Playing"

        // MPRIS names carry an instance suffix ("firefox.instance_1_2"); drop
        // it, then capitalise. A few players are officially lowercase.
        const base = player.split(".")[0]
        if (["mpv", "vlc", "cmus", "audacious"].indexOf(base) !== -1)
            return base
        return base.charAt(0).toUpperCase() + base.slice(1)
    }

    function controlIcon() {
        return status === "Playing" ? "pause" : "play_arrow"
    }

    // Artist and album on one line, so the expanded card can lead with the
    // source app without growing a fourth row.
    function subtitle() {
        const parts = []
        if (artist !== "")
            parts.push(artist)
        if (album !== "")
            parts.push(album)
        return parts.join(" \u00B7 ")
    }

    function openIsland() {
        pillHovered = true
        closeTimer.stop()
        islandVisible = true
    }

    function scheduleClose() {
        pillHovered = false
        if (!islandHovered)
            closeTimer.restart()
    }

    // ------------------------------------------------------------------
    // Data sources
    // ------------------------------------------------------------------
    Poller {
        command: "/home/davening/.config/Quickshell/scripts/media.sh"
        interval: 1000
        onValueChanged: {
            const parts = value.split("|")
            if (parts.length < 4)
                return
            root.progress = parseFloat(parts[0]) || 0
            root.positionText = parts[1] || "0:00"
            root.durationText = parts[2] || "0:00"

            const meta = parts.slice(3).join("|").split("~")
            root.status = meta[0] || "Stopped"
            root.artist = meta[1] || ""
            root.title = meta[2] || ""
            root.album = meta[3] || ""
            root.art = meta[4] || ""
            root.player = meta[5] || ""
        }
    }

    Process { id: playPause; command: ["playerctl", "play-pause"] }
    Process { id: nextTrack; command: ["playerctl", "next"] }
    Process { id: previousTrack; command: ["playerctl", "previous"] }

    // One animation value drives the island's size, radius and reveal.
    //
    // OutQuint rather than OutCubic: it decelerates for more of the way, so the
    // shape eases into its final size instead of arriving fast and stopping.
    // The duration is a little longer than a snappy tween for the same reason.
    //
    // Deliberately not a SpringAnimation: `spring` is a stiffness constant in
    // Qt and expects small single-digit values. 420 made the integrator diverge
    // and the surface grew past 11000px wide, which took the shell down.
    Behavior on islandExpansion {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuart
        }
    }

    onIslandVisibleChanged: islandExpansion = islandVisible ? 1 : 0

    // Short grace period to cover the handoff between the pill and the island
    // surfaces, so the island does not flicker shut as it appears under the
    // pointer. The island fully covers the pill, so no travel time is needed.
    Timer {
        id: closeTimer
        interval: 220
        onTriggered: if (!root.pillHovered && !root.islandHovered) root.islandVisible = false
    }

    // ------------------------------------------------------------------
    // Bar pill (stays collapsed; hovering floats the island)
    // ------------------------------------------------------------------
    Rectangle {
        id: pill
        implicitWidth: mediaRow.implicitWidth + 24
        implicitHeight: Theme.pillHeight
        radius: height / 2
        color: Theme.moduleBackground
        clip: true

        // Screen-space centre, so the island can grow outward from here.
        readonly property real sceneCenterX: mapToItem(null, width / 2, 0).x
        onSceneCenterXChanged: root.islandCenterX = sceneCenterX
        Component.onCompleted: root.islandCenterX = sceneCenterX

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onEntered: root.openIsland()
            onExited: root.scheduleClose()
            onClicked: playPause.running = true
            onWheel: function (wheel) {
                if (wheel.angleDelta.y > 0)
                    nextTrack.running = true
                else
                    previousTrack.running = true
            }
        }

        RowLayout {
            id: mediaRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "music_note"
                color: PywalColors.color6
                font.family: Theme.symbolFont
                font.pixelSize: 15
            }

            MarqueeText {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: implicitWidth
                text: root.label()
                color: PywalColors.color6
                pixelSize: 13
                maxWidth: 150
            }

            // Plain indicator: the surrounding area handles the click.
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.controlIcon()
                color: PywalColors.color4
                font.family: Theme.symbolFont
                font.pixelSize: 16
            }

            // Shape comes from Theme, so this and the island's copy below are
            // always identical. They stay two separate instances: each runs its
            // own cava process, and the island's only runs while visible.
            Cava {
                Layout.alignment: Qt.AlignVCenter
                showBackground: false
                barColor: PywalColors.color4
            }
        }
    }

    // ------------------------------------------------------------------
    // Island overlay
    // ------------------------------------------------------------------
    PanelWindow {
        id: island

        // Stays mapped until the shrink finishes, otherwise the surface would
        // disappear on the first frame of the close animation.
        visible: root.islandExpansion > 0.001

        readonly property real expansion: root.islandExpansion
        readonly property real islandWidth: root.islandCollapsedWidth
            + (root.islandExpandedWidth - root.islandCollapsedWidth) * expansion
        readonly property real islandHeight: root.islandCollapsedHeight
            + (root.islandExpandedHeight - root.islandCollapsedHeight) * expansion

        // Matches the bar pill's background alpha at expansion 0, so the
        // collapsing island blends into the pill instead of sitting on it as a
        // darker rectangle.
        readonly property real surfaceAlpha: 0.68 + (0.95 - 0.68) * expansion

        // Only near full size. Keeping it visible throughout the collapse left
        // a blue outline trailing around the shrinking shape.
        readonly property real borderAlpha: 0.55 * Math.max(0, Math.min(1, (expansion - 0.5) / 0.25))

        anchors {
            top: true
            left: true
        }
        margins {
            // Overlaps the bar so the island appears to grow out of the pill.
            top: 8
            left: Math.round(Math.max(6, Math.min(
                (island.screen ? island.screen.width : 1920) - islandWidth - 6,
                root.islandCenterX - islandWidth / 2)))
        }

        implicitWidth: islandWidth
        implicitHeight: islandHeight
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        // -1 ignores the bar's exclusive zone, so the island can sit above it.
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.focusable: false

        Rectangle {
            anchors.fill: parent
            radius: 16 + 10 * island.expansion
            color: Qt.rgba(PywalColors.background.r, PywalColors.background.g,
                           PywalColors.background.b, island.surfaceAlpha)
            border.color: Qt.rgba(PywalColors.color12.r, PywalColors.color12.g,
                                  PywalColors.color12.b, island.borderAlpha)
            border.width: island.borderAlpha > 0.01 ? 1 : 0
            clip: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onEntered: {
                    root.islandHovered = true
                    closeTimer.stop()
                }
                onExited: {
                    root.islandHovered = false
                    root.scheduleClose()
                }
                onClicked: playPause.running = true
            }

            // Compact row, matching the bar pill so the morph reads as one object.
            RowLayout {
                id: islandTopRow
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.pillHeight
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "music_note"
                    color: PywalColors.color6
                    font.family: Theme.symbolFont
                    font.pixelSize: 15
                }

                MarqueeText {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: implicitWidth
                    // Same text as the bar pill, so the collapse stays seamless.
                    text: root.label()
                    color: PywalColors.color6
                    pixelSize: 13
                    maxWidth: 150
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: root.controlIcon()
                    color: PywalColors.color4
                    font.family: Theme.symbolFont
                    font.pixelSize: 16
                }

                // Mirrors the bar pill so the island's collapsed state is a
                // pixel match for the pill it grows out of.
                Cava {
                    Layout.alignment: Qt.AlignVCenter
                    showBackground: false
                    barColor: PywalColors.color4
                    // Only runs while the island is on screen.
                    active: root.islandVisible
                }
            }

            // Full details, revealed as the island grows.
            RowLayout {
                anchors.top: islandTopRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                spacing: 12
                // Staggered: the container grows first and the details fade in
                // behind it, instead of both happening on the same clock. On
                // the way closed the content clears before the shape shrinks.
                opacity: Math.max(0, Math.min(1, (island.expansion - 0.30) / 0.55))
                visible: opacity > 0.01

                // Single slot so the placeholder can never peek out from under
                // the artwork while the image is still loading.
                Item {
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 88
                    Layout.alignment: Qt.AlignVCenter

                    readonly property bool artReady: root.art !== "" && artImage.status === Image.Ready

                    Image {
                        id: artImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.art
                        cache: true
                        asynchronous: true
                        visible: parent.artReady
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: Qt.rgba(PywalColors.color8.r, PywalColors.color8.g, PywalColors.color8.b, 0.35)
                        visible: !parent.artReady

                        Text {
                            anchors.centerIn: parent
                            text: "music_note"
                            color: PywalColors.color4
                            font.family: Theme.symbolFont
                            font.pixelSize: 34
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    // Leads with which app is playing, e.g. Spotify or Firefox.
                    MarqueeText {
                        Layout.fillWidth: true
                        text: root.sourceLabel()
                        color: PywalColors.foreground
                        pixelSize: 13
                        bold: true
                        // Caps the layout's preferred width so a long name
                        // cannot stretch the island past its fixed size.
                        maxWidth: 230
                    }

                    MarqueeText {
                        Layout.fillWidth: true
                        // Hidden while idle: the line above already reads
                        // "Nothing Playing", so showing it twice is noise.
                        visible: root.title !== ""
                        text: root.title
                        color: PywalColors.color6
                        pixelSize: 12
                        maxWidth: 230
                    }

                    MarqueeText {
                        Layout.fillWidth: true
                        visible: root.subtitle() !== ""
                        text: root.subtitle()
                        color: PywalColors.color8
                        pixelSize: 10
                        maxWidth: 230
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: 4
                        radius: 2
                        color: Qt.rgba(PywalColors.color8.r, PywalColors.color8.g, PywalColors.color8.b, 0.5)

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, root.progress))
                            height: parent.height
                            radius: 2
                            color: PywalColors.color12
                        }
                    }

                    Text {
                        text: root.positionText + " / " + root.durationText
                        color: PywalColors.color8
                        font.family: Theme.nerdFont
                        font.pixelSize: 10
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 3
                        spacing: 8

                        MediaButton {
                            glyph: "skip_previous"
                            onActivated: previousTrack.running = true
                        }

                        MediaButton {
                            glyph: root.controlIcon()
                            emphasised: true
                            onActivated: playPause.running = true
                        }

                        MediaButton {
                            glyph: "skip_next"
                            onActivated: nextTrack.running = true
                        }
                    }
                }
            }
        }
    }
}
