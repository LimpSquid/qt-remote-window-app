#include "remotewindowsocketwrapper.h"
#include <QHostAddress>
#include <QPoint>

RemoteWindowSocketWrapper::RemoteWindowSocketWrapper(QObject *parent) :
    RemoteWindowSocket(parent)
{
    address_ = QHostAddress(QHostAddress::LocalHost).toString();
    port_ = 55555;

    QObject::connect(this, &QAbstractSocket::stateChanged, this, &RemoteWindowSocketWrapper::onStateChanged);
    QObject::connect(this, &RemoteWindowSocket::sessionStateChanged, this, &RemoteWindowSocketWrapper::onSessionStateChanged);
}

RemoteWindowSocketWrapper::~RemoteWindowSocketWrapper()
{

}

QString RemoteWindowSocketWrapper::address() const
{
    return address_;
}

void RemoteWindowSocketWrapper::setAddress(const QString &address)
{
    if(address_ != address) {
        address_ = address;
        emit addressChanged();
    }
}

unsigned int RemoteWindowSocketWrapper::port() const
{
    return port_;
}

void RemoteWindowSocketWrapper::setPort(unsigned int port)
{
    port &= 0xffff;
    if(port_ != port) {
        port_ = port;
        emit portChanged();
    }
}

bool RemoteWindowSocketWrapper::isConnected() const
{
    return (RemoteWindowSocket::ConnectedState == state());
}

bool RemoteWindowSocketWrapper::isConnecting() const
{
    return (RemoteWindowSocket::ConnectingState == state());
}

bool RemoteWindowSocketWrapper::isJoined() const
{
    return (RemoteWindowSocket::SS_JOINED == sessionState());
}

void RemoteWindowSocketWrapper::connect()
{
    if(UnconnectedState == state())
        connectToHost(QHostAddress(address_), port_);
}

void RemoteWindowSocketWrapper::disconnect()
{
    if(ConnectedState == state())
        disconnectFromHost();
}

void RemoteWindowSocketWrapper::sendMousePress(double x, double y, int button, int modifiers)
{
    RemoteWindowSocket::sendMousePress(static_cast<Qt::MouseButton>(button), QPoint(x, y), static_cast<Qt::KeyboardModifier>(modifiers));
}

void RemoteWindowSocketWrapper::sendMouseRelease(double x, double y, int button, int modifiers)
{
    RemoteWindowSocket::sendMouseRelease(static_cast<Qt::MouseButton>(button), QPoint(x, y), static_cast<Qt::KeyboardModifier>(modifiers));
}

void RemoteWindowSocketWrapper::sendMouseMove(double x, double y)
{
    RemoteWindowSocket::sendMouseMove(QPoint(x, y));
}

void RemoteWindowSocketWrapper::sendKeyPress(int key, int modifiers)
{
    RemoteWindowSocket::sendKeyPress(static_cast<Qt::Key>(key), static_cast<Qt::KeyboardModifier>(modifiers));
}

void RemoteWindowSocketWrapper::sendKeyRelease(int key, int modifiers)
{
    RemoteWindowSocket::sendKeyRelease(static_cast<Qt::Key>(key), static_cast<Qt::KeyboardModifier>(modifiers));
}

void RemoteWindowSocketWrapper::onStateChanged(const QAbstractSocket::SocketState &state)
{
    switch(state) {
        case UnconnectedState:
        case ConnectedState:
            emit isConnectingChanged();
            emit isConnectedChanged();
            break;
        case ConnectingState:
            emit isConnectingChanged();
            break;
        default:
            break;
    }
}

void RemoteWindowSocketWrapper::onSessionStateChanged()
{
    emit isJoinedChanged();
}
