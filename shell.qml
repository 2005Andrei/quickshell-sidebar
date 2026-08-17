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
        focusable: true
        color: "transparent"
        property bool isVisible: false
        visible: isVisible || animation.running

        anchors {
            top: true
            right: true
            bottom: true
        }

        IpcHandler {
            target: "sidebarRight"
            function toggle(): void {
                sidebarRight.isVisible = !sidebarRight.isVisible;
            }
        }

        Item {
            Layout.rightMargin: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 10

            anchors.fill: parent

            opacity: sidebarRight.isVisible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    id: animation
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            // WlrLayershell.layer: WlrLayer.Overlay

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
    PanelWindow {
        id: linuxLogo
        color: "transparent"
        width: 300
        height: 100

        property bool isLogoVisisble: false
        visible: isLogoVisisble
        // opacity: linuxLogo.isLogoVisible ? 1.0 : 0.0


        property var modelData
        screen: modelData

        anchors {
            left: true
            bottom: true
        }

        mask: Region {
            item: content
        }

        IpcHandler {
            target: "linuxLogo"
            function toggleLogo(): void {
                linuxLogo.isLogoVisisble = !linuxLogo.isLogoVisible;
            }
        }

        Item {
            // Layout.rightMargin: 10
            // Layout.bottomMargin: 40

            anchors.fill: parent

            ColumnLayout {
                id: content

                Text {
                    text: "Activate Linux"
                    color: "white"
                    font.pointSize: 22
                }

                Text {
                    text: "Go to settings to activate Linux :)"
                    color: "white"
                    font.pointSize: 14
                }
            }
        }
    }
}

