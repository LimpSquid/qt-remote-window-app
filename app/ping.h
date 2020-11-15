#pragma once

#include <QProcess>
#include <QObject>

class Ping : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool success READ success NOTIFY successChanged)

public:
    Ping(QObject *parent = nullptr);
    ~Ping();

    bool success() const;

    Q_INVOKABLE bool start(const QString &address);
    Q_INVOKABLE void stop();

private:
    static const QString PING_PROGRAM;
    static const QString PING_COUNT_PARAMETER;

    void setSuccess(bool value);

    QProcess process_;
    bool success_;

signals:
    void successChanged();

private slots:
    void onFinished(int exitCode, const QProcess::ExitStatus &status);
};
