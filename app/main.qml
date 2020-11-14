import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import remote.window.app 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    maximumWidth: Math.max(800, captureWindow.sourceSize.width)
    maximumHeight: Math.max(600, captureWindow.sourceSize.height) + menuBar.height
    minimumWidth: 400
    minimumHeight: 300
    flags: Qt.Dialog
    title: "Remote Window Viewer"
    menuBar: MenuBar {
        id: menuBar
        Menu {
            title: "Connection"
            Action { text: "Edit..."; onTriggered: { connectionEditor.open() } }
            MenuSeparator { }
            Action { text: "Connect"; onTriggered: { remoteWindowSocket.connect() } }
            Action { text: "Disconnect"; onTriggered: { remoteWindowSocket.disconnect() } }
        }

        Menu {
            title: "Mouse and Keyboard"
            Action { text: "Edit mouse filter..."; onTriggered: { mouseFilterEditor.open() } }
            MenuSeparator { }
            Action { id: keyboardEvents; text: "Keyboard events"; checkable: true; checked: true }
        }
    }

    // Non-visual items
    CustomImageProvider { id: imageProvider }
    RemoteWindowSocket {
        id: remoteWindowSocket
        onWindowCaptureReceived: { imageProvider.data = data }
        onDisconnected: { imageProvider.clearData() }
        onError: { errorDialog.open() }
    }

    Timer {
        id: mouseMoveRateLimitTimer
        interval: 67 // 15Hz
        repeat: false
        onTriggered: { remoteWindowSocket.sendMouseMove(mouseArea.mouseX, mouseArea.mouseY) }
    }

    Timer {
        id: mouseMoveIdleTimer
        interval: 100
        repeat: false
        onTriggered: { remoteWindowSocket.sendMouseMove(mouseArea.mouseX, mouseArea.mouseY) }
    }

    Settings {
        property alias address: remoteWindowSocket.address
        property alias port: remoteWindowSocket.port
        property alias keyboardEvents: keyboardEvents.checked
        property alias mouseMoveRateLimit: mouseMoveRateLimitTimer.interval
    }

    // Visual items
    MessageDialog {
        id: errorDialog
        title: "Socket error"
        text: "A socket error occured"
        onAccepted: { close() }
    }

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
                    text: "IPv4 address:"
                }

                TextField {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: "Type here..."
                    text: remoteWindowSocket.address
                    onTextChanged: { remoteWindowSocket.address = text }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: "Port:"
                }

                TextField {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: "Type here..."
                    text: remoteWindowSocket.port
                    onTextChanged: { remoteWindowSocket.port = text }
                }
            }

            Button {
                text: "CLOSE"
                onClicked: { connectionEditor.close() }
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
                    text: "Mouse move rate limit (in ms):"
                }

                SpinBox {
                    anchors.left: parent.left
                    anchors.right: parent.right
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
        focus: (remoteWindowSocket.joined && keyboardEvents.checked)
        anchors.fill: parent
        Keys.onPressed: {
            remoteWindowSocket.sendKeyPress(event.key, event.modifiers)
            event.accepted = true
        }

        Keys.onReleased: {
            remoteWindowSocket.sendKeyRelease(event.key, event.modifiers)
            event.accepted = true
        }
    }

    ScrollView {
        anchors.fill: parent

        Image {
            id: captureWindow
            source: imageProvider.source
            anchors.fill: parent // @Commit: removedafadf

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: { remoteWindowSocket.sendMousePress(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onReleased: { remoteWindowSocket.sendMouseRelease(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onMouseXChanged: { mouseMoveRateLimitTimer.start(); mouseMoveIdleTimer.restart() }
                onMouseYChanged: { mouseMoveRateLimitTimer.start(); mouseMoveRateLimitTimer.restart() }
            }
        }
    }
}
