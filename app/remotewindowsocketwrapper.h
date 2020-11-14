#pragma once

#include <remotewindowsocket.h>

class RemoteWindowSocketWrapper : public RemoteWindowSocket
{
    Q_OBJECT
    Q_DISABLE_COPY(RemoteWindowSocketWrapper)

    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(unsigned int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool joined READ joined NOTIFY joinedChanged)

public:
    RemoteWindowSocketWrapper(QObject *parent = nullptr);
    virtual ~RemoteWindowSocketWrapper() override;

    QString address() const;
    void setAddress(const QString &address);

    unsigned int port() const;
    void setPort(unsigned int port);

    bool joined() const;

    Q_INVOKABLE void connect();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void sendMousePress(double x, double y, int button, int modifiers);
    Q_INVOKABLE void sendMouseRelease(double x, double y, int button, int modifiers);
    Q_INVOKABLE void sendMouseMove(double x, double y);
    Q_INVOKABLE void sendKeyPress(int key, int modifiers);
    Q_INVOKABLE void sendKeyRelease(int key, int modifiers);

private:
    QString address_;
    unsigned short port_;

signals:
    void addressChanged();
    void portChanged();
    void joinedChanged();

private slots:
    void onSessionStateChanged();
};
