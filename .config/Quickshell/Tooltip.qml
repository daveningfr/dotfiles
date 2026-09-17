pragma Singleton
import QtQuick

// Single shared tooltip channel. A module publishes text plus the screen X it
// wants the tooltip centred on, and one overlay window renders it.
QtObject {
    property string text: ""
    property real screenX: 0

    function show(message, x) {
        text = message
        screenX = x
    }

    // Takes the requester's own text so a module that is no longer the owner
    // cannot clear a tooltip another module has since put up.
    function hide(message) {
        if (message === undefined || message === text)
            text = ""
    }
}
