import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: root
    visible: true
    title: "Qt Transfer App"
    width: 900
    height: 620
    minimumWidth: 720
    minimumHeight: 520
    color: "#0d1117"

    readonly property color cBg:       "#0d1117"
    readonly property color cSurface:  "#161b22"
    readonly property color cCard:     "#21262d"
    readonly property color cBorder:   "#30363d"
    readonly property color cAccent:   "#58a6ff"
    readonly property color cGreen:    "#3fb950"
    readonly property color cYellow:   "#d29922"
    readonly property color cRed:      "#f85149"
    readonly property color cText:     "#e6edf3"
    readonly property color cMuted:    "#8b949e"

    property bool   appIsServer:  false
    property string appProto:     "TCP"
    property string appConnState: "idle"

    FileDialog {
        id: filePicker
        title: "Select a file to send"
        onAccepted: filePathField.text = filePicker.selectedFile.toString()
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 46
        color: cSurface
        border.color: cBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            Rectangle {
                width: 9
                height: 9
                radius: 5
                color: appConnState === "connected"  ? cGreen  :
                       appConnState === "connecting" ? cYellow :
                       appConnState === "error"      ? cRed    : cMuted

                SequentialAnimation on opacity {
                    running: appConnState === "connecting"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }

            Text {
                text: "Qt Transfer App"
                color: cText
                font.pixelSize: 14
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                height: 22
                width: protoTag.implicitWidth + 16
                radius: 4
                color: cCard
                border.color: cBorder
                border.width: 1

                Text {
                    id: protoTag
                    anchors.centerIn: parent
                    text: root.appProto
                    color: cAccent
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
            }

            Rectangle {
                height: 22
                width: modeTag.implicitWidth + 16
                radius: 4
                color: root.appIsServer ? "#1a2e1a" : "#1a1f2e"
                border.color: root.appIsServer ? cGreen : cAccent
                border.width: 1

                Text {
                    id: modeTag
                    anchors.centerIn: parent
                    text: root.appIsServer ? "SERVER" : "CLIENT"
                    color: root.appIsServer ? cGreen : cAccent
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
            }
        }
    }

    RowLayout {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            color: cSurface
            border.color: cBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 18

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "MODE"
                        color: cMuted
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: ["Client", "Server"]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                radius: 6
                                color: (index === 0 && !root.appIsServer) ||
                                       (index === 1 &&  root.appIsServer)
                                       ? cAccent : cCard
                                border.color: cBorder
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: cText
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.appIsServer = (index === 1)
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "PROTOCOL"
                        color: cMuted
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: ["TCP", "UDP"]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                radius: 6
                                color: root.appProto === modelData ? cAccent : cCard
                                border.color: cBorder
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: cText
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.appProto = modelData
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "CONNECTION"
                        color: cMuted
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    TextField {
                        id: hostField
                        Layout.fillWidth: true
                        visible: !root.appIsServer
                        placeholderText: "Host / IP"
                        text: "127.0.0.1"
                        height: 34
                        color: cText
                        placeholderTextColor: cMuted
                        font.pixelSize: 13
                        leftPadding: 10
                        background: Rectangle {
                            color: cCard
                            radius: 6
                            border.color: parent.activeFocus ? cAccent : cBorder
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                        }
                    }

                    TextField {
                        id: portField
                        Layout.fillWidth: true
                        placeholderText: "Port"
                        text: "5000"
                        height: 34
                        color: cText
                        placeholderTextColor: cMuted
                        font.pixelSize: 13
                        leftPadding: 10
                        background: Rectangle {
                            color: cCard
                            radius: 6
                            border.color: parent.activeFocus ? cAccent : cBorder
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 7
                        color: connBtnArea.pressed  ? Qt.darker(cAccent, 1.5) :
                               connBtnArea.containsMouse ? cAccent : "#1c3a5a"
                        border.color: cAccent
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.appIsServer ? "Start Server" : "Connect"
                            color: cText
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: connBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var p = parseInt(portField.text) || 5000
                                vm.init(root.appProto)
                                if (root.appIsServer) {
                                    vm.startServer(p)
                                    root.appConnState = "connected"
                                } else {
                                    vm.connectTo(hostField.text, p)
                                    root.appConnState = "connecting"
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Text {
                        text: "RECEIVED FILES"
                        color: cMuted
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: cCard
                        radius: 7
                        border.color: cBorder
                        border.width: 1
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: fileModel.count === 0
                            text: "No files yet"
                            color: cBorder
                            font.pixelSize: 12
                        }

                        ListView {
                            id: fileListView
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            model: ListModel { id: fileModel }

                            delegate: Rectangle {
                                width: fileListView.width
                                height: 38
                                radius: 5
                                color: fileItemArea.containsMouse ? "#2d333b" : "transparent"
                                Behavior on color { ColorAnimation { duration: 80 } }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Text {
                                        text: "📄"
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 30

                                        Text {
                                            text: model.name
                                            color: cText
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            visible: fileItemArea.containsMouse
                                            text: "double-click to open"
                                            color: cAccent
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                MouseArea {
                                    id: fileItemArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onDoubleClicked: Qt.openUrlExternally("file:///" + model.path)
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 30
                color: cCard
                border.color: cBorder
                border.width: 1

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: "MESSAGES"
                    color: cMuted
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                }
            }

            ListView {
                id: msgView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                bottomMargin: 8
                topMargin: 8
                model: ListModel { id: msgModel }

                onCountChanged: Qt.callLater(function() { positionViewAtEnd() })

                delegate: Item {
                    width: msgView.width
                    height: bubble.height + 6

                    Rectangle {
                        id: bubble
                        anchors.top: parent.top
                        anchors.topMargin: 3
                        anchors.right: model.outgoing ? parent.right : undefined
                        anchors.left:  model.outgoing ? undefined : parent.left
                        anchors.rightMargin: 12
                        anchors.leftMargin:  12

                        width: Math.min(bubbleText.implicitWidth + 24,
                                        msgView.width * 0.72)
                        height: bubbleText.implicitHeight + 18
                        radius: 12
                        color: model.outgoing ? "#1c3a5a" : cCard
                        border.color: model.outgoing ? cAccent : cBorder
                        border.width: 1

                        Text {
                            id: bubbleText
                            anchors.fill: parent
                            anchors.margins: 10
                            text: model.text
                            color: cText
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 52
                color: cSurface
                border.color: cBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    TextField {
                        id: msgInput
                        Layout.fillWidth: true
                        height: 34
                        placeholderText: "Type a message…"
                        color: cText
                        placeholderTextColor: cMuted
                        font.pixelSize: 13
                        leftPadding: 12
                        background: Rectangle {
                            color: cCard
                            radius: 7
                            border.color: parent.activeFocus ? cAccent : cBorder
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                        }
                        Keys.onReturnPressed: doSendMessage()
                    }

                    Rectangle {
                        width: 72
                        height: 34
                        radius: 7
                        color: sendMsgArea.pressed        ? Qt.darker(cAccent, 1.5) :
                               sendMsgArea.containsMouse  ? cAccent : "#1c3a5a"
                        border.color: cAccent
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Send"
                            color: cText
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: sendMsgArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: doSendMessage()
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: cBorder }

            Rectangle {
                Layout.fillWidth: true
                height: 118
                color: cSurface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: "FILE TRANSFER"
                        color: cMuted
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: filePathField
                            Layout.fillWidth: true
                            height: 34
                            placeholderText: "Select or type a file path…"
                            color: cText
                            placeholderTextColor: cMuted
                            font.pixelSize: 12
                            leftPadding: 10
                            background: Rectangle {
                                color: cCard
                                radius: 7
                                border.color: parent.activeFocus ? cAccent : cBorder
                                border.width: 1
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                            }
                        }

                        Rectangle {
                            width: 68
                            height: 34
                            radius: 7
                            color: browseArea.pressed       ? "#2a2f3a" :
                                   browseArea.containsMouse ? "#252a35" : cCard
                            border.color: cBorder
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "Browse"
                                color: cText
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: browseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: filePicker.open()
                            }
                        }

                        Rectangle {
                            width: 80
                            height: 34
                            radius: 7
                            opacity: filePathField.text.trim() !== "" ? 1.0 : 0.4
                            color: sendFileArea.pressed       ? Qt.darker(cGreen, 1.5) :
                                   sendFileArea.containsMouse ? cGreen : "#1a3a25"
                            border.color: cGreen
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "Send File"
                                color: cText
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: sendFileArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var p = filePathField.text.trim()
                                    if (p !== "")
                                        vm.sendFile(p)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: cCard
                            border.color: cBorder
                            border.width: 1

                            Rectangle {
                                width: parent.width * (vm.progress / 100.0)
                                height: parent.height
                                radius: 5
                                color: vm.progress >= 100 ? cGreen : cAccent
                                Behavior on width {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                                }
                            }
                        }

                        Text {
                            text: vm.progress + "%"
                            color: vm.progress >= 100 ? cGreen : cAccent
                            font.pixelSize: 12
                            font.family: "Courier New"
                            font.bold: true
                            width: 38
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: cBorder }

            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#090d12"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 3

                    Text {
                        text: "STATUS"
                        color: cMuted
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    ListView {
                        id: logView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel { id: logModel }
                        verticalLayoutDirection: ListView.BottomToTop

                        delegate: Text {
                            width: logView.width
                            text: model.entry
                            color: model.isError ? cRed : cMuted
                            font.pixelSize: 11
                            font.family: "Courier New"
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: vm

        function onStatusChanged(s) {
            addLog(s, false)
            if (s.indexOf("Connected") >= 0 || s.indexOf("Listening") >= 0)
                root.appConnState = "connected"
            else if (s.indexOf("Error") >= 0)
                root.appConnState = "error"
        }

        function onMessageReceived(msg) {
            msgModel.append({ text: msg, outgoing: false })
        }

        function onFileReceived(path) {
            var parts = path.replace("\\", "/").split("/")
            var name  = parts[parts.length - 1]
            fileModel.append({ name: name, path: path })
            addLog("File saved: " + name, false)
        }

        function onProgressChanged(value) {
            if (value >= 100)
                addLog("Transfer complete ✓", false)
        }
    }

    function addLog(entry, isError) {
        logModel.append({ entry: entry, isError: isError || false })
        if (logModel.count > 300)
            logModel.remove(0)
    }

    function doSendMessage() {
        var t = msgInput.text.trim()
        if (t === "") return
        vm.sendMessage(t)
        msgModel.append({ text: t, outgoing: true })
        msgInput.text = ""
    }
}
