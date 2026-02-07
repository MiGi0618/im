cmake_minimum_required(VERSION 3.16)

project(IMClientMVP VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml WebSockets)

qt_standard_project_setup()

set(SOURCES
    main.cpp
    WebSocketClient.cpp
    MessageModel.cpp
    UserModel.cpp
)

set(HEADERS
    WebSocketClient.h
    MessageModel.h
    UserModel.h
)

qt_add_executable(IMClientMVP
    MANUAL_FINALIZATION
    ${SOURCES}
    ${HEADERS}
    resources.qrc
)

target_link_libraries(IMClientMVP PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::WebSockets
)

if(WIN32)
    set_target_properties(IMClientMVP PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

qt_finalize_executable(IMClientMVP)
