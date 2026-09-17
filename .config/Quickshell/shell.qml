import QtQuick
import QtQuick.Layouts
import Quickshell
import "."
import "lib"
import "modules"
import "overlays"

// The bar itself. Everything visible comes from a module in modules/, and the
// shared pieces (Theme, Tooltip, Pill, Cava ...) live in lib/ and the root.
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    Item {
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 4

        // ---------------- left: workspaces + media ----------------
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            WorkspacesModule {}

            MediaModule {}
        }

        // ---------------- center: clock ----------------
        ClockModule {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // ---------------- right ----------------
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            // Hardware: temperature, processor, memory, battery.
            ModuleGroup {
                TemperatureModule { showBackground: false }
                CpuModule { showBackground: false }
                RamModule { showBackground: false }
                BatteryModule { showBackground: false }
            }

            // Connectivity: network, bluetooth, audio.
            ModuleGroup {
                NetworkModule { showBackground: false }
                BluetoothModule { showBackground: false }
                VolumeModule { showBackground: false }
            }

            // On its own, so it stays a distinct target to click.
            NotificationsModule {}
        }
    }

    // Single tooltip surface, fed by every module through the Tooltip singleton.
    TooltipOverlay {}
}
