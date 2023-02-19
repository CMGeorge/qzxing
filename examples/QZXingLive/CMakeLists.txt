cmake_minimum_required(VERSION 3.24)
project(QZXing)

SET(PROJECT_VERSION "3.3")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_WARN_ON)
#if build example...
find_package(Qt6
    REQUIRED
    COMPONENTS
        Core
        Qml
        Quick
        QuickControls2
        Multimedia
        Svg
)

qt_add_executable(QZXingLive
    main.cpp
    application.h
    application.cpp
    native.h
    native.cpp

    #resource
    qml.qrc
)
add_compile_definitions(QZXING_QML)
target_link_libraries(QZXingLive PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Multimedia
    Qt${QT_VERSION_MAJOR}::Svg
    qzxing
)
