pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    implicitWidth: parent.width
    radius: 15
    Layout.margins: 5
    color: Qt.rgba(0, 0, 0, 0.9)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 0

        ColumnLayout {
            spacing: 2

            RowLayout {
                spacing: 10

                Text {
                    id: weatherIcon
                    font.family: "Weather Icons"
                    font.pixelSize: 34
                    color: "#89dceb"
                    text: "\uf002"
                    y: 0

                    SequentialAnimation on y {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: -4
                            duration: 2500
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 0
                            duration: 2500
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                ColumnLayout {
                    spacing: -2

                    Text {
                        text: "23°"
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: "#cdd6f4"
                    }

                    Text {
                        text: "Brașov"
                        font.pixelSize: 13
                        font.weight: Font.Light
                        color: "#a6adc8"
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            Text {
                Layout.alignment: Qt.AlignRight
                text: "Feels like 20°"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#a6adc8"
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignRight

                RowLayout {
                    spacing: 5
                    Text {
                        text: ""
                        font.pixelSize: 12
                        color: "#89b4fa"
                    }
                    Text {
                        text: "8°"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#cdd6f4"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 12
                    color: "#45475a"
                }

                RowLayout {
                    spacing: 5
                    Text {
                        text: ""
                        font.pixelSize: 12
                        color: "#f38ba8"
                    }
                    Text {
                        text: "12°"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#cdd6f4"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 12
                    color: "#45475a"
                }

                RowLayout {
                    spacing: 5
                    Text {
                        text: ""
                        font.pixelSize: 12
                        color: "#94e2d5"
                    }
                    Text {
                        text: "65%"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#cdd6f4"
                    }
                }
            }
        }
    }
}
