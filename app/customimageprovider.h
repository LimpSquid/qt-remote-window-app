#pragma once

#include <QQmlParserStatus>

class ImageProvider;
class QQmlEngine;
class CustomImageProvider : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_DISABLE_COPY(CustomImageProvider)
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(QByteArray data READ data WRITE setData NOTIFY dataChanged)
    Q_PROPERTY(QString source READ source NOTIFY sourceChanged)

public:
    CustomImageProvider(QObject *parent = nullptr);
    virtual ~CustomImageProvider() override;

    QString source() const;

    QByteArray data() const;
    void setData(const QByteArray &data);
    Q_INVOKABLE void clearData();

private:
    virtual void classBegin() override;
    virtual void componentComplete() override;

    ImageProvider *provider_;
    QQmlEngine *qmlEngine_;
    QByteArray data_;
    QString providerId_;
    QString id_;

signals:
    void sourceChanged();
    void dataChanged();
};

