pragma ComponentBehavior: Bound;
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets


Rectangle {
    id: root
    anchors.fill: parent
    anchors.leftMargin: 15
    radius: 15
    color: "#11111B"

    property date theDate: new Date(2026, 11, 15)
    property int daysLeft: 0
    property string currentQuote: ""

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            daysLeft = Math.ceil((theDate - new Date()) / (1000 * 60 * 60 * 24))
        }
    }

    FileView {
        id: specialLink
        path: "/home/andrei/.config/quickshell/countdown/link.txt"
        blockLoading: true
    }

    Process {
        id: writeQuoteFile
    }

    Timer {
        interval: 300000 
        running: true
        repeat: true
        triggeredOnStart: true 
        onTriggered: {
            let req = new XMLHttpRequest();
            req.open("GET", specialLink.text().trim());
            req.onreadystatechange = function() {
                if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
                    try {
                        let data = JSON.parse(req.responseText);
                        if (data.quote && data.quote !== currentQuote) {
                            currentQuote = data.quote;
                            quote.text = currentQuote + " - Elizabeth";
                            
                            let safeQuote = currentQuote.replace(/'/g, "'\\''");
                            writeQuoteFile.command = ["sh", "-c", "echo '" + safeQuote + "' > ~/.cache/fastfetch_quote.txt"];
                            writeQuoteFile.running = true;
                        }
                    } catch(e) {
                        console.log("Failed to parse quote");
                    }
                }
            }
            req.send();
        }
    }

    ColumnLayout {
        id: countdownRootLayout
        anchors.fill: parent
        spacing: 20

        Item {
            Layout.fillHeight: true
        }
        


        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: bigNum
                text: daysLeft
                font.family: "Quicksand"
                font.bold: true
                font.pixelSize: 64
                color: "cyan"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                id: daysLeftText
                text: "days left til great happiness"
                font.italic: true
                font.pixelSize: 10
                color: "cyan"
                Layout.alignment: Qt.AlignHCenter
            }

        }

        Text {
            id: quote
            text: "No internet connection."
            font.italic: true
            font.pixelSize: 12
            color: "cyan"
            Layout.alignment: Qt.AlignHCenter

            wrapMode: Text.WordWrap
            Layout.maximumWidth: 180
            horizontalAlignment: Text.AlignHCenter 
        }


        Item {
            Layout.fillHeight: true
        }
    }

}
