#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QDebug>

#include <Qt>
#include "qzxing.h"
#include "application.h"

int main(int argc, char *argv[])
{
//    qputenv("QT_QUICK_BACKEND","software");
//    qputenv("QSG_RHI_PREFER_SOFTWARE_RENDERER","1");
//    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);

    QZXing::registerQMLTypes();


    Application customApp;
    customApp.checkPermissions();

    return app.exec();
}
