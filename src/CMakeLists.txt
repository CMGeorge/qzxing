cmake_minimum_required(VERSION 3.3)
project(QZXing)

find_package(Qt6 COMPONENTS Core  REQUIRED)

find_package(Qt6 COMPONENTS Gui REQUIRED)
find_package(Qt6 COMPONENTS Multimedia )
find_package(Qt6 REQUIRED Svg Quick QuickControls2)

SET(BIGINT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zxing/bigint)
SET(WIN32_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/zxing/win32/zxing)
SET(ZXING_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/zxing/zxing)

SET(PROJECT_VERSION "3.3")
set(CMAKE_AUTOMOC ON)
set(CMAKE_WARN_ON)
message("----------------------------------------")
if (BUILD_SHARED_LIBS)
    message("Will add SHARED DEFINITIONS...")
    add_definitions(-DQZXING_LIBRARY)
endif()

set(SOURCES

    CameraImageWrapper.cpp
    CameraImageWrapper.h
    ImageHandler.cpp
    ImageHandler.h
    QZXing.cpp
    QZXing.h
    QZXing_global.h
)

if(QZXING_MULTIMEDIA)

    #Qt5: LIST(APPEND SOURCES QZXingFilter.cpp QZXingFilter.h)
    LIST(APPEND SOURCES QZXingFilterVideoSink.cpp QZXingFilterVideoSink.h)
    add_definitions(-DQZXING_MULTIMEDIA)

    SET(QZXING_USE_QML ON)

endif(QZXING_MULTIMEDIA)

if(QZXING_USE_QML)
    LIST(APPEND SOURCES QZXingImageProvider.cpp QZXingImageProvider.h)
    add_definitions(-DQZXING_QML)
endif(QZXING_USE_QML)

if(QZXING_USE_ENCODER)
    add_definitions(-DENABLE_ENCODER_GENERIC -DENABLE_ENCODER_QR_CODE)
endif(QZXING_USE_ENCODER)

add_library(qzxing "" ${SOURCES})
install(TARGETS qzxing LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    COMPONENT library)
#TODO: Forced this on MAC.. Jack why...
if (APPLE)
    add_definitions(-DNO_ICONV)
endif()

if(WIN32)
    add_subdirectory(zxing/win32)
    if(MSVC)
        add_definitions(-D__STDC_LIMIT_MACROS)
    endif(MSVC)

    add_definitions(-DNO_ICONV)
endif(WIN32)

if(ANDROID)
    add_definitions(-DNO_ICONV)
endif()

if(VS_WINRT_COMPONENT)
    add_definitions(-DNO_ICONV)
endif(VS_WINRT_COMPONENT)

add_subdirectory(zxing/bigint)

add_subdirectory(zxing/zxing)

target_link_libraries(qzxing
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::CorePrivate
    Qt${QT_VERSION_MAJOR}::Gui)
message(Multimedia? ${QZXING_MULTIMEDIA})
if(QZXING_MULTIMEDIA)
    target_link_libraries(qzxing Qt${QT_VERSION_MAJOR}::Multimedia)
    target_compile_definitions(qzxing PUBLIC -DQZXING_MULTIMEDIA)
endif(QZXING_MULTIMEDIA)

if(QZXING_USE_QML)
    message("Working")
    target_link_libraries(qzxing
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::QuickControls2)
    target_compile_definitions(qzxing PUBLIC -DQZXING_QML)
endif(QZXING_USE_QML)

if(QZXING_USE_ENCODER)
    target_compile_definitions(qzxing PUBLIC -DENABLE_ENCODER_GENERIC -DENABLE_ENCODER_QR_CODE)
endif(QZXING_USE_ENCODER)

if(QZXING_USE_DECODER_QR_CODE)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_QR_CODE)
endif()

if(QZXING_USE_DECODER_1D_BARCODES)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_1D_BARCODES)
endif()

if(QZXING_USE_DECODER_DATA_MATRIX)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_DATA_MATRIX)
endif()

if(QZXING_USE_DECODER_AZTEC)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_AZTEC)
endif()

if(QZXING_USE_DECODER_PDF17)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_PDF17)
endif()

# Change Global Definitions depending on how you want to use the library
#target_compile_definitions(qzxing PUBLIC DISABLE_LIBRARY_FEATURES)

# Target includes
target_include_directories(qzxing
    PRIVATE
    .
    zxing
    zxing/win32/zxing
    zxing/zxing
    zxing/bigint
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)
set(QZXing_PUBLIC_HEADERS CameraImageWrapper.h
    ImageHandler.h
    QZXing.h
    qzxing_global.h

)

set_target_properties(qzxing PROPERTIES PUBLIC_HEADER "${QZXing_PUBLIC_HEADERS}")

install(TARGETS qzxing
    EXPORT qzxingTargets
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    PUBLIC_HEADER DESTINATION "include/QZXing"
    #                      COMPONENT library
)
install(EXPORT qzxingTargets
    FILE qzxingTargets.cmake
    NAMESPACE QZXing::
    DESTINATION lib/cmake/QZXing
)

# Create a version file
include(CMakePackageConfigHelpers)
write_basic_package_version_file("QZXing.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Create a config file
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/QZXing.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/QZXing.cmake"
    INSTALL_DESTINATION "lib/cmake/QZXing"
    NO_SET_AND_CHECK_MACRO
)

# Install the config and version files
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/QZXing.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/QZXing.cmake"
    DESTINATION "lib/cmake/QZXing"
)


configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/QZXingConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/QZXingConfig.cmake"
    INSTALL_DESTINATION "lib/cmake/QZXing"
    NO_SET_AND_CHECK_MACRO
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/QZXingConfig.cmake"
    DESTINATION "lib/cmake/QZXing"
)
#install(TARGETS qzxing PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/qzxing")

