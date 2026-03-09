#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "service/TransferService.h"
#include "viewmodel/TransferViewModel.h"

int main(int argc, char **argv)
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);
    app.setApplicationName("Qt Transfer App");
    app.setApplicationVersion("1.0.0");

    bool isServer = false;
    int  port     = 5000;
    for (int i = 1; i < argc; ++i) {
        QString arg = QString::fromUtf8(argv[i]);
        if (arg == QLatin1String("-s") || arg == QLatin1String("--server"))
            isServer = true;
        if ((arg == QLatin1String("-p") || arg == QLatin1String("--port")) && i + 1 < argc)
            port = QString::fromUtf8(argv[++i]).toInt();
    }

    TransferService service;

    if (isServer) {
        service.init("TCP");
        service.startServer(port);
        qInfo() << "Headless server running on port" << port;
        return app.exec();
    }

    TransferViewModel vm(&service);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("vm", &vm);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML";
        return -1;
    }

    return app.exec();
}