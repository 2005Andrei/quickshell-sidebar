pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: parent.width
    radius: 15
    Layout.margins: 5
    color: Qt.rgba(0, 0, 0, 0.9)

    // "location": "Spitalul General C.F.Brasov, 60, Bulevardul 15 Noiembrie, Centrul Nou, Bra\u0219ov, Zona Metropolitan\u0103 Bra\u0219ov, Bra\u0219ov, 500097, Rom\u00e2nia",
    // "temp": "10.381500244140625",
    // "feels": "7.960375785827637",
    // "rain": "0.0",
    // "precipitation": "0.0",
    // "high": "12.531501",
    // "low": "7.4315"

    FileView {
        id: jsonFile
        path: "/home/andrei/.cache/.weather_cache"

        watchChanges: true
        onFileChanged: this.reload()

        onAdapterUpdated: writeAdapter()

        printErrors: true
        blockLoading: true
    }

    property var jsonData: JSON.parse(jsonFile.text())
    property string location: jsonData["location"]
    property string temp: jsonData["temp"]
    property string feels: jsonData["feels"]
    property string rain: jsonData["rain"]
    property string precipitation: jsonData["precipitation"]
    property string high: jsonData["high"]
    property string low: jsonData["low"]
    property string icon: jsonData["icon"]

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
                    text: root.icon
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
                        text: root.temp + "\u2103"
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: "#cdd6f4"
                    }

                    Text {
                        leftPadding: -5
                        text: root.location
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
                text: "Feels like " + root.feels + "\u2103"
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
                        text: root.low + "\u2103"
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
                        text: root.high + "\u2103"
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
                        text: (parseInt(root.precipitation) < parseInt(root.rain)) ? root.precipitation + "%" : root.rain + "%"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#cdd6f4"
                    }
                }
            }
        }
    }
}
