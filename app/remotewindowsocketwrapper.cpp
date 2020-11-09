#include "remotewindowsocketwrapper.h"
#include <QHostAddress>
#include <QPoint>

RemoteWindowSocketWrapper::RemoteWindowSocketWrapper(QObject *parent) :
    RemoteWindowSocket(parent)
{
    address_ = QHostAddress(QHostAddress::LocalHost).toString();
    port_ = 55555;
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

void RemoteWindowSocketWrapper::connect()
{
    connectToHost(QHostAddress(address_), port_);
}

void RemoteWindowSocketWrapper::sendMousePress(double x, double y, int button, int modifiers)
{
    RemoteWindowSocket::sendMousePress(Qt::MouseButton(button), QPoint(x, y), Qt::KeyboardModifier(modifiers));
}

void RemoteWindowSocketWrapper::sendMouseRelease(double x, double y, int button, int modifiers)
{
    RemoteWindowSocket::sendMouseRelease(Qt::MouseButton(button), QPoint(x, y), Qt::KeyboardModifier(modifiers));
}

void RemoteWindowSocketWrapper::sendMouseMove(double x, double y)
{
    RemoteWindowSocket::sendMouseMove(QPoint(x, y));
}
