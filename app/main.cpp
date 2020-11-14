#include "customimageprovider.h"
#include "remotewindowsocketwrapper.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <remotewindowserver.h>
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    app.setOrganizationName("LimpSquid");
    app.setOrganizationDomain("github.com/LimpSquid/qt-remote-window-app");
    app.setApplicationName("qt-remote-window-app");

    qmlRegisterType<CustomImageProvider>("remote.window.app", 1, 0, "CustomImageProvider");
    qmlRegisterType<RemoteWindowSocketWrapper>("remote.window.app", 1, 0, "RemoteWindowSocket");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
