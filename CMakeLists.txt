cmake_minimum_required(VERSION 3.24)
project(QZXing)

find_package(Qt6 COMPONENTS Core REQUIRED)

if(NOT ${Qt6Core_VERSION} VERSION_EQUAL 6.3.0)
message(FATAL_ERROR "Version 6.3.0 looks to be the only one version for android which works with camera.
PLEASE USE THAT VERSION UNTIL FUTURE NOTICE!!!!
After this version camera is not correctly displayed.
It must be streched in to display correctly so the decoder is not working
Issue confirmed on 6.4.2, 6.5 and 6.6-dev.
To make it work us Qt 6.3.0 and ndk 22 ONLY.
Detected version:  ${Qt6Core_VERSION}")
endif()
SET(PROJECT_VERSION "3.3")
set(CMAKE_AUTOMOC ON)
set(CMAKE_WARN_ON)
#if build example...
#add_compile_definitions(-DQZXING_USE_QML)
set(QZXING_MULTIMEDIA ON)
set(QZXING_USE_ENCODER ON)
#DECODE QR_CODE
set(QZXING_USE_DECODER_QR_CODE ON)
set(QZXING_USE_DECODER_1D_BARCODES ON)
set(QZXING_USE_DECODER_DATA_MATRIX ON)
set(QZXING_USE_DECODER_AZTEC ON)
set(QZXING_USE_DECODER_PDF17 ON)
add_subdirectory(src)
add_subdirectory(examples)
