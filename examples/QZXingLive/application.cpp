#include "application.h"
#include <QDebug>
#include <QCoreApplication>

#if QT_VERSION < 0x060000
#include "native.h"
#endif


#if defined(Q_OS_ANDROID)

#if QT_VERSION < 0x060100
    #include <QAndroidJniObject>
    #include <QtAndroid>
#else
    #include <QJniObject>
#endif

#endif // Q_OS_ANDROID

#if QT_CONFIG(permissions)
#include <QPermissions>
#endif

Application::Application()
{
    //both signals will be connected to the same function for
    //simplicity

    connect(this, &Application::onPermissionsGranted,
            this, &Application::initializeQML);

    connect(this, &Application::onPermissionsDenied,
            this, &Application::initializeQML);

#if QT_VERSION < 0x060000
  NativeHelpers::registerApplicationInstance(this);
#endif
    QCameraPermission permission;
  qDebug()<<"Current permision is: "<<qApp->checkPermission(permission);
    qApp->requestPermission(permission, this, [this](){});
}

void Application::initializeQML()
{
#if QT_VERSION < 0x060200
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
#elif QT_VERSION < 0x060500
    engine.load(QUrl(QStringLiteral("qrc:/main_qt6_2.qml")));
#else
    engine.load(QUrl(QStringLiteral("qrc:/main_qt6_5_fix.qml")));
#endif // QT_VERSION < 0x060200
}

void Application::checkPermissions()
{
#if defined(Q_OS_ANDROID)
    //intentionally called in the C++ thread since it is blocking and will continue after the check
    qDebug() << "About to request permissions";

    #if QT_VERSION < 0x060000
        QAndroidJniObject::callStaticMethod<void>("org/ftylitak/qzxing/Utilities",
                                        "requestQZXingPermissions",
                                        "(Landroid/app/Activity;)V",
                                        QtAndroid::androidActivity().object());
    #else
        emit onPermissionsGranted();
    #endif
    qDebug() << "Permissions granted";
#else
    emit onPermissionsGranted();
#endif //Q_OS_ANDROID
}
