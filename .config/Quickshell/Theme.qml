pragma Singleton
import QtQuick

// Shared palette and typography. Modules read from here instead of hardcoding
// colours or font families, so a Pywal change reaches every module at once.
QtObject {
    // Bar pill surface.
    readonly property color moduleBackground: Qt.rgba(PywalColors.background.r, PywalColors.background.g, PywalColors.background.b, 0.68)

    // Overlay card surface, more opaque so text stays readable over windows.
    readonly property color cardBackground: Qt.rgba(PywalColors.background.r, PywalColors.background.g, PywalColors.background.b, 0.95)
    readonly property color cardBorder: Qt.rgba(PywalColors.color12.r, PywalColors.color12.g, PywalColors.color12.b, 0.55)

    // Subtle wash used for hover feedback.
    readonly property color hoverWash: Qt.rgba(PywalColors.color12.r, PywalColors.color12.g, PywalColors.color12.b, 0.24)

    readonly property string nerdFont: "0xProto Nerd Font Mono"
    readonly property string symbolFont: "Material Symbols Outlined"

    readonly property int barHeight: 46
    readonly property int pillHeight: 32
    readonly property int pillRadius: 10

    // Audio visualiser shape. Both Cava instances (bar pill and media island)
    // read these so the two stay identical. cavaBarCount must match the `bars`
    // value in cava.conf, otherwise cava emits values the bar throws away.
    readonly property int cavaBarCount: 12
    readonly property int cavaBarSize: 15
    readonly property int cavaBarGap: 3
}
