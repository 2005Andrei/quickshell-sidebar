import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Shapes

Rectangle {
    id: root
    color: Qt.rgba(0, 0, 0, 0.7) //  Qt.rgba(103, 105, 124, 0.3)
    focus: true
    implicitWidth: parent.width
    implicitHeight: 20
    Layout.margins: 5
    radius: 15

    // colors
    property color taskBorder: Qt.rgba(120 / 255, 130 / 255, 170 / 255, 0.25)// "#e0e0e0"
    property color lsTaskBg: Qt.rgba(10, 23, 15, 0.1) //  Qt.rgba(30 / 255, 34 / 255, 48 / 255, 0.22)
    property color ndtaskColor: "white"
    property color dtaskColor: "white"

    // button colors
    property color taskbtnColor: "black"
    property color btnColor: "white"
    property color btnColorHover: "#2ecc71"
    property color btnPressed: "gray"
    property color btnSelected: "#5d5fef" // "#0D1321"
    property color btnTextColor: "white"
    property color btnTextUnselectedColor: "#8f90a6"

    property color secondaryTextColor: "#757575"

    property color modalColor: "#1c1c28"
    property color modalBorderColor: Qt.rgba(255, 255, 255, 0.08)
    property color modalTextColor: "white"

    property bool showAddDialog: false
    property int unfinishedCount: 0
    property int doneCount: 0

    Component.onCompleted: updateCounts()

    ListModel {
        id: todoModel
        ListElement {
            description: "get more work done"
            done: false
        }
        ListElement {
            description: "sitting"
            done: true
        }
    }

    function updateCounts() {
        let u = 0;
        let d = 0;
        for (let i = 0; i < todoModel.count; ++i) {
            if (todoModel.get(i).done) {
                d++;
            } else {
                u++;
            }
        }
        unfinishedCount = u;
        doneCount = d;
    }

    function addTask() {
        if (taskInput.text.trim().length > 0) {
            todoModel.append({
                description: taskInput.text.trim(),
                done: false
            });
            taskInput.text = "";
            root.showAddDialog = false;
            tabBar.setCurrentIndex(0);
            updateCounts();
        }
    }

    Keys.onPressed: event => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                tabBar.incrementCurrentIndex();
            } else if (event.key === Qt.Key_PageUp) {
                tabBar.decrementCurrentIndex();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_N) {
            root.showAddDialog = true;
            taskInput.forceActiveFocus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false;
            event.accepted = true;
        }
    }

    Component {
        id: taskDelegate
        Item {
            width: ListView.view ? ListView.view.width : 0

            readonly property bool isDoneTab: ListView.view && ListView.view.objectName === "doneList"
            readonly property bool showItem: isDoneTab ? model.done : !model.done

            visible: showItem
            implicitHeight: showItem ? contentCard.implicitHeight + 10 : 0

            Rectangle {
                id: contentCard
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                implicitHeight: rowLayout.implicitHeight + 20
                color: root.lsTaskBg
                radius: 6
                border.color: root.taskBorder

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Label {
                        text: model.description
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font.pixelSize: 15
                        font.strikeout: model.done
                        color: model.done ? root.dtaskColor : root.ndtaskColor
                    }

                    Button {
                        id: doneBtn
                        text: model.done ? "Undo" : "Done"
                        implicitHeight: 32
                        background: Rectangle {
                            radius: 10
                            implicitHeight: parent.height
                            implicitWidth: 80

                            color: {
                                if (doneBtn.pressed)
                                    return root.btnPressed;
                                else if (doneBtn.hovered)
                                    return root.btnColorHover;
                                else
                                    return root.btnColor;
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                        }

                        contentItem: Text {
                            text: doneBtn.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.taskbtnColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        scale: doneBtn.pressed ? 1.07 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }

                        onClicked: {
                            todoModel.setProperty(index, "done", !model.done);
                            root.updateCounts();
                        }
                    }

                    Button {
                        text: "Delete"
                        implicitHeight: 32 // Layout.prefferedHeight
                        contentItem: Text {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: parent.text
                            color: root.taskbtnColor
                        }

                        background: Rectangle {
                            radius: 10
                            implicitHeight: parent.height
                            implicitWidth: 80
                        }

                        onClicked: {
                            todoModel.remove(index);
                            root.updateCounts();
                        }
                    }
                }
            }
        }
    }

    // main layout
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
                    text: "Unfinished"

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
                    text: "Done"
                    implicitHeight: 30

                    contentItem: Text {
                        text: tabBtn2.text
                        color: tabBar.currentIndex === 1 ? root.btnTextColor : root.btnTextUnselectedColor
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
                        color: "transparent" // tabBar.currentIndex === 1 ? "transparent" : "black"
                    }
                }
            }

            Rectangle {
                id: movingBg
                radius: 15
                color: root.btnSelected
                z: -1
                implicitWidth: tabBtn1.width
                implicitHeight: tabBtn1.height
                y: 0

                scale: 1.0

                states: [
                    State {
                        name: "tab0"
                        when: tabBar.currentIndex === 0
                        PropertyChanges {
                            target: movingBg
                            x: tabBtn1.x
                        }
                    },
                    State {
                        name: "tab1"
                        when: tabBar.currentIndex === 1
                        PropertyChanges {
                            target: movingBg
                            x: tabBtn2.x
                        }
                    }
                ]

                transitions: Transition {
                    SequentialAnimation {
                        NumberAnimation {
                            target: movingBg
                            property: "scale"
                            to: 0.85
                            duration: 100
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: movingBg
                            property: "x"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            target: movingBg
                            property: "scale"
                            to: 1.0
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            // Rectangle {
            //     id: movingBg
            //     radius: 15
            //     color: root.btnSelected
            //     z: -1
            //     implicitWidth: tabBtn1.width
            //     implicitHeight: tabBtn1.height
            //     y: 0
            //     x: tabBar.currentIndex === 0 ? tabBtn1.x : tabBtn2.x
            //
            //     Behavior on x {
            //         NumberAnimation {
            //             duration: 200
            //             easing.type: Easing.InOutQuad
            //         }
            //     }
            // }
        }

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            clip: true

            Item {
                Label {
                    anchors.centerIn: parent
                    text: "You should get to work"
                    font.pixelSize: 16
                    color: root.secondaryTextColor
                    visible: root.unfinishedCount === 0
                }
                ListView {
                    id: unfinishedList
                    objectName: "unfinishedList"
                    anchors.fill: parent
                    anchors.margins: 10
                    model: todoModel
                    delegate: taskDelegate
                    bottomMargin: 80
                }
            }

            Item {
                Label {
                    anchors.centerIn: parent
                    text: "You haven't finished anything young blood"
                    font.pixelSize: 16
                    color: root.secondaryTextColor
                    visible: root.doneCount === 0
                }
                ListView {
                    id: doneList
                    objectName: "doneList"
                    anchors.fill: parent
                    anchors.margins: 10
                    model: todoModel
                    delegate: taskDelegate
                    bottomMargin: 80
                }
            }
        }
    }

    Rectangle {
        id: dropdown
        implicitWidth: 120
        implicitHeight: 40
        color: "transparent"
        radius: 15
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 25

        ComboBox {
            id: control
            anchors.centerIn: parent
            implicitWidth: parent.implicitWidth
            implicitHeight: parent.implicitHeight
            model: ["First", "Second", "Third", "Fourth"]

            delegate: ItemDelegate {
                id: delegate

                implicitWidth: 90
                implicitHeight: 30
                Layout.leftMargin: 15

                hoverEnabled: true

                required property var model
                required property int index

                contentItem: Text {
                    id: modelData
                    text: delegate.model[control.textRole]
                    color: delegate.highlighted ? root.btnSelected : root.btnColor
                    font: control.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: delegate.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                    radius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // highlighted: control.highlightedIndex === index
            }

            // from: https://doc.qt.io/qt-6/qtquickcontrols-customize.html
            indicator: Item {
                id: dropdownCanvas
                x: control.width - width - control.rightPadding
                y: control.topPadding + (control.availableHeight - height) / 2
                implicitWidth: 12
                implicitHeight: 8

                Canvas {
                    anchors.centerIn: parent
                    contextType: "2d"
                    implicitHeight: parent.implicitHeight
                    implicitWidth: parent.implicitWidth

                    Connections {
                        target: control
                        function onPressedChanged() {
                            dropdownCanvas.requestPaint();
                        }
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = control.pressed ? root.btnSelected : root.btnSelected;
                        context.fill();
                    }

                    rotation: control.popup.visible ? 0 : 90

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutSine
                        }
                    }
                }
            }

            contentItem: Text {
                leftPadding: 10
                rightPadding: control.indicator.width + control.spacing

                text: control.displayText
                font: control.font
                color: control.pressed || dropdownPopup.visible ? root.btnSelected : "white"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }

            background: Rectangle {
                color: "transparent"
                radius: 15
                implicitWidth: 120
                implicitHeight: 40
                border.color: root.btnSelected
                border.width: control.visualFocus ? 2 : 1

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            popup: Popup {
                id: dropdownPopup
                y: control.height + 5
                width: control.width
                height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin) + 10

                enter: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            property: "y"
                            from: control.height - 10
                            to: control.height + 5
                            duration: 200
                            easing.type: Easing.OutBack
                        }
                    }
                }

                exit: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: 150
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            property: "y"
                            from: control.height + 5
                            to: control.height - 10
                            duration: 150
                            easing.type: Easing.InQuad
                        }
                    }
                }

                contentItem: ListView {
                    id: dropdownList
                    clip: true
                    implicitHeight: contentHeight + 14
                    model: control.popup.visible ? control.delegateModel : null
                    currentIndex: control.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    implicitWidth: dropdownPopup.implicitWidth
                    Layout.leftMargin: 4
                    // border.color: root.btnSelected
                    color: Qt.rgba(255, 255, 255, 0.3)
                    radius: 15
                }
            }
        }

        // ComboBox {
        //     anchors.centerIn: parent
        //     model: ListModel {
        //         id: model
        //         ListElement {
        //             text: "hello"
        //         }
        //         ListElement {
        //             text: "bye"
        //         }
        //         ListElement {
        //             text: "sth"
        //         }
        //     }
        //     background: Rectangle {
        //         color: "transparent"
        //         implicitWidth: 80
        //         implicitHeight: 30
        //     }
        // }
    }

    // add task button
    Rectangle {
        id: fabButton
        width: 45
        height: 45
        radius: 15
        color: root.btnSelected
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        scale: mouseArea.pressed ? 0.85 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Item {
            anchors.centerIn: parent
            width: 18
            height: 18

            Rectangle {
                width: parent.width
                height: 2.5
                color: "#FFFFFF"
                anchors.centerIn: parent
                radius: 2
            }

            Rectangle {
                width: 2.5
                height: parent.height
                color: "#FFFFFF"
                anchors.centerIn: parent
                radius: 2
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.showAddDialog = true;
                taskInput.forceActiveFocus();
            }
        }
    }

    // modal

    Item {
        anchors.fill: parent
        z: 999
        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        onVisibleChanged: {
            if (visible) {
                taskInput.forceActiveFocus();
            } else {
                taskInput.text = "";
                root.forceActiveFocus();
            }
        }

        Rectangle {
            radius: 15
            anchors.fill: parent
            color: "#80000000"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.showAddDialog = false
            }
        }

        // dialog box
        Rectangle {
            id: dialogBox
            anchors.centerIn: parent
            width: Math.min(parent.width - 40, 400)
            implicitHeight: dialogLayout.implicitHeight + 32
            color: root.modalColor
            radius: 8

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: dialogLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 16

                Label {
                    text: "Add Task"
                    font.pixelSize: 18
                    font.bold: true
                    color: root.modalTextColor
                }

                TextField {
                    id: taskInput
                    color: root.modalTextColor
                    Layout.fillWidth: true
                    placeholderText: "Task description"
                    font.pixelSize: 15
                    padding: 13
                    background: Rectangle {
                        radius: 15
                        implicitHeight: 30
                        color: "transparent"
                        border.color: root.modalBorderColor
                        border.width: 2
                    }
                    onAccepted: root.addTask()
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10

                    Button {
                        id: cancel
                        text: "Cancel"
                        flat: true
                        padding: 10
                        implicitWidth: 80
                        scale: 1.0

                        // what hapenned in the end could have been simply achieved without states and transitions but it will do for now
                        contentItem: Text {
                            text: parent.text
                            color: root.btnTextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: root.btnSelected
                            border.width: cancel.hovered ? 1.0 : 0.5

                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        states: [
                            State {
                                name: "hovered"
                                when: cancel.hovered
                                PropertyChanges {
                                    target: cancel
                                    scale: 0.9
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: "*"
                                to: "hovered"
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: cancel
                                        property: "scale"
                                        to: 1.05
                                        duration: 120
                                        easing.type: Easing.OutQuad
                                    }

                                    NumberAnimation {
                                        target: cancel
                                        property: "scale"
                                        to: 0.9
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: "*"
                                NumberAnimation {
                                    target: cancel
                                    property: "scale"
                                    to: 1.0
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                        ]

                        onClicked: root.showAddDialog = false
                    }

                    Button {
                        id: add
                        text: "Add"
                        flat: true
                        padding: 10
                        implicitWidth: 80
                        scale: 1.0
                        contentItem: Text {
                            text: parent.text
                            color: root.btnTextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: root.btnSelected
                            border.width: add.hovered ? 1.0 : 0.5

                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        states: [
                            State {
                                name: "hovered"
                                when: add.hovered
                                PropertyChanges {
                                    target: add
                                    scale: 1.05
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: "*"
                                to: "hovered"
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: add
                                        property: "scale"
                                        to: 0.90
                                        duration: 120
                                        easing.type: Easing.OutQuad
                                    }

                                    NumberAnimation {
                                        target: add
                                        property: "scale"
                                        to: 1.05
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: "*"
                                NumberAnimation {
                                    target: add
                                    property: "scale"
                                    to: 1.0
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                        ]

                        enabled: taskInput.text.trim().length > 0
                        onClicked: root.addTask()
                    }

                    // Button {
                    //     text: "Add"
                    //     enabled: taskInput.text.trim().length > 0
                    //     onClicked: root.addTask()
                    // }
                }
            }
        }
    }
}
