cmake_minimum_required(VERSION 3.24)
project(QZXing)

SET(PROJECT_VERSION "3.3")
set(CMAKE_AUTOMOC ON)
set(CMAKE_WARN_ON)
#if build example...
#add_compile_definitions(-DQZXING_USE_QML)
set(QZXING_MULTIMEDIA ON)

add_subdirectory(src)
add_subdirectory(examples)
