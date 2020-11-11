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
            title: qsTr("Connection")
            Action { text: qsTr("Edit..."); onTriggered: { popup.open() } }
            MenuSeparator { }
            Action { text: qsTr("Connect"); onTriggered: { remoteWindowSocket.connect() } }
            Action { text: qsTr("Disconnect"); onTriggered: { remoteWindowSocket.disconnect() } }
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
        id: mouseMoveTimer
        interval: 10
        repeat: false
        onTriggered: { remoteWindowSocket.sendMouseMove(mouseArea.mouseX, mouseArea.mouseY) }
    }

    Settings {
        property alias address: remoteWindowSocket.address
        property alias port: remoteWindowSocket.port
    }

    // Visual items
    MessageDialog {
        id: errorDialog
        title: "Socket error"
        text: "A socket error occured"
        onAccepted: { close() }
    }

    Popup {
        id: popup
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        Column {
            anchors.fill: parent
            anchors.margins: 16
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
                onClicked: { popup.close() }
            }
        }
    }

    ScrollView {
        anchors.fill: parent

        Image {
            id: captureWindow
            source: imageProvider.source

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: { remoteWindowSocket.sendMousePress(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onReleased: { remoteWindowSocket.sendMouseRelease(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onMouseXChanged: { mouseMoveTimer.restart() }
                onMouseYChanged: { mouseMoveTimer.restart() }
            }
        }
    }
}
