pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls


Rectangle {
    id: root
    implicitWidth: parent.width
    radius: 15
    Layout.margins: 5
    color: Qt.rgba(0, 0, 0, 0.9)

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

    ColumnLayout {
        anchors.fill: parent


        SwipeView {
            id: time

            Layout.fillWidth: true
            Layout.fillHeight: true
     
            currentIndex: 1

            Item {
                id: weather
                
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

                        // Rectangle {
                        //     Layout.preferredWidth: 1
                        //     Layout.preferredHeight: 12
                        //     color: "#45475a"
                        // }

                        // RowLayout {
                        //     spacing: 5
                        //     Text {
                        //         text: ""
                        //         font.pixelSize: 12
                        //         color: "#94e2d5"
                        //     }
                        //     Text {
                        //         text: (parseInt(root.precipitation) < parseInt(root.rain)) ? root.precipitation + "%" : root.rain + "%"
                        //         font.pixelSize: 13
                        //         font.weight: Font.Medium
                        //         color: "#cdd6f4"
                        //     }
                        // }
                        }
                    }
                }
            }

            Item {
                id: secondPage

                property string timeLocal: "--:--:--"
                property string timeNY: "--:--:--"
                property string timeBangkok: "--:--:--"
                property string timeLondon: "--:--:--"

                Process {
                    id: tzProcess
                    running: true
                    command: [
                        "bash",
                        "-c",
                        "while true; do echo \"$(date +'%H:%M:%S'),$(TZ='America/New_York' date +'%H:%M:%S'),$(TZ='Asia/Bangkok' date +'%H:%M:%S'),$(TZ='Europe/London' date +'%H:%M:%S')\"; sleep 1; done"
                    ]

                    stdout: SplitParser {
                        onRead: data => {
                            let line = data.trim()
                            let times = line.split(",")

                            if (times.length === 4) {
                                secondPage.timeLocal = times[0]
                                secondPage.timeNY = times[1]
                                secondPage.timeBangkok = times[2]
                                secondPage.timeLondon = times[3]
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12 
                        spacing: 6 

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 4 
                            spacing: 8

                            Text {
                                text: "\uf017" 
                                font.pixelSize: 13
                                color: "#89b4fa" 
                            }
                            Text {
                                text: "World Clock"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                font.capitalization: Font.AllUppercase
                                color: "#a6adc8"
                                Layout.fillWidth: true
                            }
                        }

                        ClockRow {
                            city: "Local"
                            time: secondPage.timeLocal
                            showDivider: true
                        }
                        ClockRow {
                            city: "New York"
                            time: secondPage.timeNY
                            showDivider: true
                        }
                        ClockRow {
                            city: "Bangkok"
                            time: secondPage.timeBangkok
                            showDivider: true
                        }
                        ClockRow {
                            city: "London"
                            time: secondPage.timeLondon
                            showDivider: false
                        }
                    }
                }

                component ClockRow: Item {
                    id: row
                    property string city: ""
                    property string time: "--:--:--"
                    property bool showDivider: true

                    Layout.fillWidth: true
                    Layout.preferredHeight: 22 

                    RowLayout {
                        anchors.fill: parent
                        spacing: 5

                        Text {
                            text: row.city
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#cdd6f4"
                            Layout.fillWidth: true 
                        }

                        Text {
                            text: row.time
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            font.family: "monospace"
                            color: "#89b4fa"
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }

                    Rectangle {
                        visible: row.showDivider
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: "#313244"
                    }
                }
            }


        }

            


        PageIndicator {
            id: indicator

            count: time.count
            currentIndex: time.currentIndex

            anchors.bottom: view.bottom
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
