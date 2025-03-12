cmake_minimum_required(VERSION 3.24)
project(QZXingLive)

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
if (QT_VERSION_MAJOR GREATER 6 OR (QT_VERSION_MAJOR EQUAL 6 AND QT_VERSION_MINOR GREATER_EQUAL 8))
    qt_add_ios_ffmpeg_libraries(QZXingLive)
endif()
if(ANDROID)
    SET(QT_ANDROID_PLATFORM 23)
    # Set the location of the Java source files
#    set(QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android/")
    message("Setting extra target properties")
    set_target_properties(QZXingLive PROPERTIES
        ANDROID_MANIFEST ${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml
        ANDROID_RES_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/android/res/
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android/
    )
    message("Se path ${CMAKE_CURRENT_SOURCE_DIR}/android/ as android files location")
    #set_property(TARGET QZXingLive APPEND
    #    PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #        ${CMAKE_CURRENT_SOURCE_DIR}/android/
    #    )
    qt_android_generate_deployment_settings(QZXingLive)
else()
    set_target_properties(QZXingLive PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        MACOSX_BUNDLE_GUI_IDENTIFIER ro.wesell.${PROJECT_NAME}
    )
endif()
