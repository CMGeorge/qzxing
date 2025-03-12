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
//    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);/Users/cmgeorge/Dev/build/qzxing/Qt_6_6_2_for_iOS/Debug/src/CMakeFiles/qzxing.dir/Info.plist
    QGuiApplication app(argc, argv);
    app.setApplicationName("QZXingLive");
    app.setOrganizationName("CMG Development");
    app.setOrganizationDomain("ro.wesell");
    QZXing::registerQMLTypes();


    Application customApp;
    customApp.checkPermissions();

    return app.exec();
}
