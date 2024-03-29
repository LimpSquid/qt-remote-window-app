import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import remote.window.app 1.0

ApplicationWindow {
    visible: true
    width: (autoScreenResize.checked && socket.isJoined) ?
                Math.max(minimumWidth, captureWindow.sourceSize.width) : 800
    height: (autoScreenResize.checked && socket.isJoined) ?
                Math.max(minimumHeight, captureWindow.sourceSize.height +  menuBar.height) : 600
    maximumWidth: Math.max(800, captureWindow.sourceSize.width)
    maximumHeight: Math.max(600, captureWindow.sourceSize.height) + menuBar.height
    minimumWidth: 400
    minimumHeight: 300
    flags: Qt.Dialog
    title: "Remote Window Viewer"
    menuBar: MenuBar {
        id: menuBar
        Menu {
            title: "&Connection"
            Action { text: "Edit..."; onTriggered: { connectionEditor.open() } }
            Action { id: autoConnect; text: "Auto connect"; checkable: true; checked: false }
            MenuSeparator { }
            Action { text: "Connect"; enabled: (!socket.isConnected && !socket.isConnecting); onTriggered: { socket.connect() } }
            Action { text: "Disconnect"; enabled: socket.isConnected || socket.isConnecting; onTriggered: { socket.isConnected ? socket.disconnect() :
                                                                                                                                 socket.cancelConnect() } }
        }

        Menu {
            title: "&Other settings"
            Action { text: "Edit mouse filter(s)..."; onTriggered: { mouseFilterEditor.open() } }
            Action { id: keyboardIntegration; text: "Keyboard integration"; checkable: true; checked: true }
            MenuSeparator { }
            Action { id: autoScreenResize; text: "Automatic screen resize"; checkable: true; checked: true }

        }

        Menu {
            title: "&Chat"
            Action { text: "Show chatbox..."; enabled: socket.isConnected; onTriggered: { chatBoxDialog.open() } }
        }
    }

    // Non-visual items
    Ping { id: ping }
    ListModel { id: chatBoxModel; onCountChanged: { if(count > 500) remove(0, 20) } }
    CustomImageProvider { id: imageProvider }
    RemoteWindowSocket {
        id: socket
        onAddressChanged: { ping.stop(); pingTimer.restart() }
        onPortChanged: { ping.stop(); pingTimer.restart() }
        onWindowCaptureReceived: { imageProvider.data = data }
        onDisconnected: { imageProvider.clearData() }
        onChatMessageReceived: { chatBoxModel.append({ msg }) }
    }

    Timer {
        id: mouseMoveRateLimitTimer
        interval: 67 // 15Hz
        repeat: false
        onTriggered: { socket.sendMouseMove(mouseArea.mouseX, mouseArea.mouseY) }
    }

    Timer {
        id: mouseMoveIdleTimer
        interval: 100
        repeat: false
        onTriggered: { socket.sendMouseMove(mouseArea.mouseX, mouseArea.mouseY) }
    }

    Timer {
        id: pingTimer
        interval: 5000
        repeat: true
        running: !socket.isJoined
        triggeredOnStart: true
        onTriggered: { ping.start(socket.address) }
    }

    Timer {
        id: autoConnectTimer
        interval: 1000
        repeat: true
        running: !socket.isConnected && !socket.isConnecting && ping.success && autoConnect.checked
        onTriggered: { socket.connect() }
    }

    Settings {
        property alias address: socket.address
        property alias port: socket.port
        property alias autoConnect: autoConnect.checked
        property alias keyboardIntegration: keyboardIntegration.checked
        property alias mouseMoveRateLimit: mouseMoveRateLimitTimer.interval
        property alias autoScreenResize: autoScreenResize.checked
    }

    // Visual items
    Popup {
        id: connectionEditor
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: parent.width / 3
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 16

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    text: "IPv4 address:"
                }

                TextField {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: "Type here..."
                    text: socket.address
                    onTextChanged: { socket.address = text }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    text: "Port:"
                }

                TextField {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: "Type here..."
                    text: socket.port
                    onTextChanged: { socket.port = text }
                }
            }

            Button {
                text: "CLOSE"
                onClicked: { connectionEditor.close() }
            }
        }
    }

    MessageDialog {
        id: chatBoxDialog
        title: "Chatbox"
        modality: Qt.NonModal

        Item {
            anchors.fill: parent
            implicitWidth: 400
            implicitHeight: 300

            ListView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: chatMessage.top
                anchors.margins: 16
                model: chatBoxModel
                onCountChanged: { positionViewAtEnd() }
                delegate: Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: modelData
                }
            }

            TextField {
                id: chatMessage
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                placeholderText: "Type here..."
                Keys.onReturnPressed: {
                    socket.sendChatMessage(chatMessage.text)
                    chatMessage.text = ""
                }
            }
        }
    }

    Popup {
        id: mouseFilterEditor
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: parent.width / 3
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 16

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    text: "Mouse move rate limit (in ms):"
                }

                SpinBox {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    editable: true
                    from: 10
                    to: 500
                    value: mouseMoveRateLimitTimer.interval
                    onValueChanged: { mouseMoveRateLimitTimer.interval = value }
                }
            }

            Button {
                text: "CLOSE"
                onClicked: { mouseFilterEditor.close() }
            }
        }
    }

    Item {
        focus: (socket.isJoined && keyboardIntegration.checked &&
                !connectionEditor.visible && !mouseFilterEditor.visible)
        anchors.fill: parent
        Keys.onPressed: {
            socket.sendKeyPress(event.key, event.modifiers)
            event.accepted = true
        }

        Keys.onReleased: {
            socket.sendKeyRelease(event.key, event.modifiers)
            event.accepted = true
        }
    }

    Image {
        id: captureWindow
        source: imageProvider.source
        visible: socket.isJoined

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: { socket.sendMousePress(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
            onReleased: { socket.sendMouseRelease(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
            onMouseXChanged: { mouseMoveRateLimitTimer.start(); mouseMoveIdleTimer.restart() }
            onMouseYChanged: { mouseMoveRateLimitTimer.start(); mouseMoveIdleTimer.restart() }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: !socket.isJoined
        color: "lightsteelblue"

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !socket.isConnecting

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Label.AlignHCenter
                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                font.pointSize: 18
                text: "Host at '" + socket.address + "' online:"
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Label.AlignHCenter
                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                font.pointSize: 18
                text: ping.success ? "yes" : "no"
                color: ping.success ? "green" : "red"
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: socket.isConnecting

            BusyIndicator {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 64
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Label.AlignHCenter
                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                font.pointSize: 18
                text: "Connecting..."
            }
        }
    }
}
