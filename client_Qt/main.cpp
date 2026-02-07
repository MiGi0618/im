#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "WebSocketClient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("IM Client MVP");
    app.setApplicationVersion("0.1");

    qmlRegisterType<WebSocketClient>("IMClient", 1, 0, "WebSocketClient");

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
