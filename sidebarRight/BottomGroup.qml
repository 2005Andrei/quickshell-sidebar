pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitWidth: parent.width
    implicitHeight: 20
    color: Qt.rgba(0, 0, 0, 0.9)
    radius: 15
    focus: true
    Layout.margins: 5

    property color colSurface: Qt.rgba(0, 0, 0, 0.9)
    property color colOnSurface: "#CDD6F4"
    property color colSubtext: "#A6ADC8"
    property color colLayer2: "#313244"
    property color colOnLayer2: "#CDD6F4"
    property color colPrimary: "#5d5fef" // this could work too:#89B4FA
    property color colOnPrimary: "white"
    property color colSecondaryContainer: "#45475A"
    property color colOnSecondaryContainer: "#CDD6F4"
    property color colErrorContainer: "#ff3b7c" // this #F38BA8 worked with #89B4FA
    property color colOnErrorContainer: "white" // #11111B

    // button colors
    property color btnColor: "white"
    property color btnColorHover: "#2ecc71"
    property color btnPressed: "gray"
    property color btnSelected: "#5d5fef"
    property color btnTextColor: "white"
    property color btnTextUnselectedColor: "#8f90a6"

    property int focusTime: 1500
    property int pomodoroSecondsLeft: 1500
    property int pomodoroLapDuration: 1500
    property bool pomodoroRunning: false
    property bool pomodoroBreak: false
    property bool pomodoroLongBreak: false
    property int pomodoroCycle: 0

    property real stopwatchTime: 0
    property bool stopwatchRunning: false

    Timer {
        id: pomodoroTimerInternal
        interval: 1000
        running: root.pomodoroRunning
        repeat: true
        onTriggered: {
            if (root.pomodoroSecondsLeft > 0) {
                root.pomodoroSecondsLeft--;
            } else {
                root.pomodoroRunning = false;
            }
        }
    }

    Timer {
        id: stopwatchTimerInternal
        interval: 10
        running: root.stopwatchRunning
        repeat: true
        onTriggered: root.stopwatchTime += 1
    }

    Keys.onPressed: event => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                tabBar.currentIndex = (tabBar.currentIndex + 1) % 2;
            } else if (event.key === Qt.Key_PageUp) {
                tabBar.currentIndex = (tabBar.currentIndex - 1 + 2) % 2;
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_S) {
            if (tabBar.currentIndex === 0)
                root.pomodoroRunning = !root.pomodoroRunning;
            else
                root.stopwatchRunning = !root.stopwatchRunning;
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            if (tabBar.currentIndex === 0) {
                root.pomodoroRunning = false;
                root.pomodoroSecondsLeft = root.pomodoroLapDuration;
            } else {
                root.stopwatchRunning = false;
                root.stopwatchTime = 0;
            }
            event.accepted = true;
        }
    }

    // main laoyout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.bottomMargin: 25
            Layout.topMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            TabBar {
                id: tabBar
                anchors.fill: parent
                currentIndex: swipeView.currentIndex
                background: Rectangle {
                    topLeftRadius: 15
                }

                TabButton {
                    id: tabBtn1
                    implicitHeight: 30
                    text: "Pomodoro"

                    contentItem: Text {
                        text: tabBtn1.text
                        color: tabBar.currentIndex === 0 ? root.btnTextColor : root.btnTextUnselectedColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }

                    background: Rectangle {
                        radius: 15
                        color: "transparent" // tabBar.currentIndex === 0 ? "transparent" : "black"

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }

                TabButton {
                    id: tabBtn2
                    text: "Stopwatch"
                    implicitHeight: 30

                    contentItem: Text {
                        text: tabBtn2.text
                        color: tabBar.currentIndex === 1 ? root.btnTextColor : root.btnTextUnselectedColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    background: Rectangle {
                        radius: 15
                        color: "transparent" // tabBar.currentIndex === 1 ? "transparent" : "black"

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: movingBg
                radius: 15
                color: root.btnSelected
                z: -1
                width: tabBtn1.width
                height: tabBtn1.height
                y: 0

                states: [
                    State {
                        name: "tab0"
                        when: tabBar.currentIndex === 0
                        PropertyChanges {
                            target: movingBg
                            x: tabBtn1.x
                            width: tabBtn1.width
                        }
                    },
                    State {
                        name: "tab1"
                        when: tabBar.currentIndex === 1
                        PropertyChanges {
                            target: movingBg
                            x: tabBtn2.x
                            width: tabBtn2.width
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "tab0"
                        to: "tab1"
                        SequentialAnimation {
                            NumberAnimation {
                                target: movingBg
                                property: "width"
                                to: (tabBtn2.x - tabBtn1.x) + tabBtn2.width
                                duration: 150
                                easing.type: Easing.OutQuad
                            }

                            ParallelAnimation {
                                NumberAnimation {
                                    target: movingBg
                                    property: "x"
                                    to: tabBtn2.x
                                    duration: 200
                                    easing.type: Easing.OutBack
                                }
                                NumberAnimation {
                                    target: movingBg
                                    property: "width"
                                    to: tabBtn2.width
                                    duration: 200
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                    },
                    Transition {
                        from: "tab1"
                        to: "tab0"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: movingBg
                                    property: "x"
                                    to: tabBtn1.x
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                                NumberAnimation {
                                    target: movingBg
                                    property: "width"
                                    to: (tabBtn2.x - tabBtn1.x) + tabBtn2.width
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                            NumberAnimation {
                                target: movingBg
                                property: "width"
                                to: tabBtn1.width
                                duration: 200
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                ]
            }
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: tabBar.currentIndex

            // ==========================================
            // pomodoro
            // ==========================================
            Item {
                id: pomodoroTab
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 30

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 200
                        height: 200

                        Canvas {
                            anchors.fill: parent
                            property real progress: root.pomodoroLapDuration > 0 ? (root.pomodoroSecondsLeft / root.pomodoroLapDuration) : 0

                            onProgressChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                ctx.beginPath();
                                ctx.arc(width / 2, height / 2, width / 2 - 8, 0, 2 * Math.PI);
                                ctx.lineWidth = 8;
                                ctx.strokeStyle = root.colLayer2;
                                ctx.stroke();

                                ctx.beginPath();
                                ctx.arc(width / 2, height / 2, width / 2 - 8, -Math.PI / 2, -Math.PI / 2 + (progress * 2 * Math.PI));
                                ctx.lineWidth = 8;
                                ctx.strokeStyle = root.colPrimary;
                                ctx.stroke();
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    let minutes = Math.floor(root.pomodoroSecondsLeft / 60).toString().padStart(2, '0');
                                    let seconds = Math.floor(root.pomodoroSecondsLeft % 60).toString().padStart(2, '0');
                                    return `${minutes}:${seconds}`;
                                }
                                font.pixelSize: 40
                                color: root.colOnSurface
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.pomodoroLongBreak ? "Long break" : root.pomodoroBreak ? "Break" : "Focus"
                                font.pixelSize: 14
                                color: root.colSubtext
                            }
                        }

                        Rectangle {
                            radius: 18
                            color: root.colLayer2
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                            }
                            width: 36
                            height: 36

                            Text {
                                anchors.centerIn: parent
                                color: root.colOnLayer2
                                text: root.pomodoroCycle + 1
                            }
                        }
                    }

                    // pomodoro buttons
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        Button {
                            implicitHeight: 35
                            implicitWidth: 90
                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: root.pomodoroRunning ? "Pause" : (root.pomodoroSecondsLeft === root.focusTime) ? "Start" : "Resume"
                                color: root.pomodoroRunning ? root.colOnSecondaryContainer : root.colOnPrimary
                                font.pixelSize: 16
                            }
                            background: Rectangle {
                                color: parent.down ? Qt.darker(root.pomodoroRunning ? root.colSecondaryContainer : root.colPrimary, 1.2) : (root.pomodoroRunning ? root.colSecondaryContainer : root.colPrimary)
                                radius: 8
                            }
                            onClicked: root.pomodoroRunning = !root.pomodoroRunning
                        }

                        Button {
                            implicitHeight: 35
                            implicitWidth: 90
                            enabled: (root.pomodoroSecondsLeft < root.pomodoroLapDuration) || root.pomodoroCycle > 0 || root.pomodoroBreak
                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "Reset"
                                color: root.colOnErrorContainer
                                font.pixelSize: 16
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            background: Rectangle {
                                color: parent.down ? Qt.darker(root.colErrorContainer, 1.2) : root.colErrorContainer
                                radius: 8
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            onClicked: {
                                root.pomodoroRunning = false;
                                root.pomodoroSecondsLeft = root.pomodoroLapDuration;
                            }
                        }
                    }
                }
            }

            // ==========================================
            // stopwatch
            // ==========================================
            Item {
                id: stopwatchTab

                Item {
                    anchors {
                        fill: parent
                        topMargin: 8
                        leftMargin: 16
                        rightMargin: 16
                    }

                    RowLayout {
                        id: elapsedIndicator
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            font.pixelSize: 40
                            color: root.colOnSurface
                            text: {
                                let totalSeconds = Math.floor(root.stopwatchTime) / 100;
                                let minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
                                let seconds = Math.floor(totalSeconds % 60).toString().padStart(2, '0');
                                return `${minutes}:${seconds}`;
                            }
                        }
                    }

                    RowLayout {
                        id: controlButtons

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: elapsedIndicator.bottom
                            bottomMargin: -40
                        }
                        spacing: 10

                        Button {
                            implicitHeight: 35
                            implicitWidth: 90
                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 16
                                color: root.stopwatchRunning ? root.colOnSecondaryContainer : root.colOnPrimary
                                text: root.stopwatchRunning ? "Pause" : root.stopwatchTime === 0 ? "Start" : "Resume"
                            }
                            background: Rectangle {
                                radius: 8
                                color: parent.down ? Qt.darker(root.stopwatchRunning ? root.colSecondaryContainer : root.colPrimary, 1.2) : (root.stopwatchRunning ? root.colSecondaryContainer : root.colPrimary)
                            }
                            onClicked: root.stopwatchRunning = !root.stopwatchRunning
                        }

                        Button {
                            implicitHeight: 35
                            implicitWidth: 90
                            enabled: root.stopwatchTime > 0

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 16
                                text: "Reset"
                                color: root.colOnErrorContainer
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            background: Rectangle {
                                radius: 8
                                color: parent.down ? Qt.darker(root.colErrorContainer, 1.2) : root.colErrorContainer
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            onClicked: {
                                root.stopwatchRunning = false;
                                root.stopwatchTime = 0;
                            }
                        }
                    }
                }
            }
        }
    }
}
