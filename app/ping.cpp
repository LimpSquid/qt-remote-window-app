#include "ping.h"

const QString Ping::PING_PROGRAM = "ping";
#ifdef Q_OS_WIN
const QString Ping::PING_COUNT_PARAMETER = "-n";
#else
const QString Ping::PING_COUNT_PARAMETER = "-c";
#endif

Ping::Ping(QObject *parent) :
    QObject(parent)
{
    success_ = false;

    QObject::connect(&process_, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &Ping::onFinished);
}

Ping::~Ping()
{

}

bool Ping::success() const
{
    return success_;
}

bool Ping::start(const QString &address)
{
    if(process_.state() != QProcess::NotRunning)
        return false;

    QStringList args;
    bool result = false;

    args.append(PING_COUNT_PARAMETER);
    args.append(QString::number(1));
    args.append(address);

    process_.start(PING_PROGRAM, args);
    if(process_.waitForStarted(1000))
        result = true;
    else {
        process_.terminate();
        process_.kill();
    }
    return result;
}

void Ping::stop()
{
    if(process_.state() != QProcess::Running)
        return;
    process_.terminate();
    process_.kill();
}

void Ping::setSuccess(bool value)
{
    if(success_ != value) {
        success_ = value;
        emit successChanged();
    }
}

void Ping::onFinished(int exitCode, const QProcess::ExitStatus &status)
{
    setSuccess(QProcess::NormalExit == status && 0 == exitCode);
}
