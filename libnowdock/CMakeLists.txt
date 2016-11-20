find_package(ECM 1.8.0 REQUIRED NO_MODULE)

set (REQUIRED_QT_VERSION "5.3.0")
find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Quick Gui Sql Qml Svg)
find_package(KF5WindowSystem REQUIRED)

find_package(KF5 REQUIRED COMPONENTS
    Plasma
    PlasmaQuick
)

set(CMAKE_AUTOMOC ON)

set(nowdock_SRCS
    nowdockplugin.cpp
    panelwindow.cpp
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
