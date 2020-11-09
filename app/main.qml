import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import remote.window.app 1.0

Window {
    visible: true
    width: 1024
    height: 768

    // Non-visual items
    CustomImageProvider { id: imageProvider }
    RemoteWindowSocket {
        id: remoteWindowSocket
        onWindowCaptureReceived: { imageProvider.data = data }
        Component.onCompleted: { connect() }
    }

    // Visual items
    ScrollView {
        anchors.fill: parent

        Image {
            id: captureWindow
            source: imageProvider.source

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPressed: { remoteWindowSocket.sendMousePress(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onReleased: { remoteWindowSocket.sendMouseRelease(mouse.x, mouse.y, mouse.button, mouse.modifiers) }
                onMouseXChanged: { remoteWindowSocket.sendMouseMove(mouse.x, mouse.y) }
                onMouseYChanged: { remoteWindowSocket.sendMouseMove(mouse.x, mouse.y) }
            }
        }
    }
}
