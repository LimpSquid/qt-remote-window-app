#include "customimageprovider.h"
#include <QQuickImageProvider>
#include <QPixmap>
#include <QUuid>

class ImageProvider : public QQuickImageProvider
{
public:
    ImageProvider(const QByteArray * const data, const QString * const id) :
        QQuickImageProvider(Pixmap),
        data_(data),
        id_(id)
    {

    }

    virtual QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        if(data_->isEmpty() || id != *id_) {
            QSize defaultSize = requestedSize.isValid() ? requestedSize : QSize(10, 10);
            if(nullptr != size)
                *size = defaultSize;

            QPixmap pixmap(defaultSize);
            pixmap.fill(QColor(Qt::transparent));
            return pixmap;
        }

        QPixmap pixmap;
        pixmap.loadFromData(*data_);
        if(nullptr != size)
            *size = pixmap.size();
        if(requestedSize.isValid() && pixmap.size() != requestedSize)
            pixmap = pixmap.scaled(requestedSize);
        return pixmap;
    }

private:
    const QByteArray * const data_;
    const QString * const id_;
};

CustomImageProvider::CustomImageProvider(QObject *parent) :
    QObject(parent),
    QQmlParserStatus()
{
    provider_ = new ImageProvider(&data_, &id_);
    qmlEngine_ = nullptr;
    providerId_ = QUuid::createUuid().toByteArray().toBase64(QByteArray::OmitTrailingEquals);
    id_ = QUuid::createUuid().toByteArray().toBase64(QByteArray::OmitTrailingEquals);
}

CustomImageProvider::~CustomImageProvider()
{
    if(qmlEngine_)
        qmlEngine_->removeImageProvider(providerId_);

}

QString CustomImageProvider::source() const
{
    if(data_.isEmpty())
        return QString();
    return "image://" + providerId_ + "/" + id_;
}

QByteArray CustomImageProvider::data() const
{
    return data_;
}

void CustomImageProvider::setData(const QByteArray &data)
{
    if(data_ != data) {
        id_ = QUuid::createUuid().toByteArray().toBase64(QByteArray::OmitTrailingEquals);
        data_ = data;

        emit dataChanged();
        emit sourceChanged();
    }
}

void CustomImageProvider::clearData()
{
    setData(QByteArray());
}

void CustomImageProvider::classBegin()
{
    qmlEngine_ = qmlEngine(this);
    if(qmlEngine_)
        qmlEngine_->addImageProvider(providerId_, provider_);
}

void CustomImageProvider::componentComplete()
{

}
