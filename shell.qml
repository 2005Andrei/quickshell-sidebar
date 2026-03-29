import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "sidebarRight"

ShellRoot {
    PanelWindow {
        id: sidebarRight

        implicitWidth: 450
        visible: false

        IpcHandler {
            target: "sidebarRight"
            function toggle(): void {
                if (!sidebarRight) {
                    sidebarRight.opacity = 0;
                }
                sidebarRight.visible = !sidebarRight.visible;
            }
        }

        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 10
            bottom: 10
            right: 10
        }

        // WlrLayershell.layer: WlrLayer.Overlay

        color: "transparent"
        // implicitWidth: 450
        focusable: true

        Rectangle {
            id: sidebarBg
            anchors.fill: parent
            radius: 15
            color: "transparent"
            clip: true
        }

        ColumnLayout {
            id: bigRow
            anchors.fill: parent
            implicitHeight: parent.height
            implicitWidth: parent.width - 10
            spacing: 10

            TopGroup {
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            CenterGroup {
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            BottomGroup {
                Layout.alignment: Qt.AlignBottom
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
