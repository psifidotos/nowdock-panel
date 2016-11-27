set (REQUIRED_QT_VERSION "5.6.0")
list( APPEND CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wreorder")

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Quick Qml)

find_package(KF5 REQUIRED COMPONENTS
    Plasma
    PlasmaQuick
    WindowSystem
)

set(CMAKE_AUTOMOC ON)

set(nowdock_SRCS
    nowdockplugin.cpp
    panelwindow.cpp
    xwindowinterface.cpp
    abstractinterface.cpp
)
    
add_library(nowdockplugin SHARED ${nowdock_SRCS})

target_link_libraries(nowdockplugin
        Qt5::Quick
        Qt5::Qml
        KF5::Plasma
        KF5::PlasmaQuick
        KF5::WindowSystem
)

install(TARGETS nowdockplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/nowdock)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/nowdock)
