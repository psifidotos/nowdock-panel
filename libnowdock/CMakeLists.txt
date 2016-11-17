set(CMAKE_AUTOMOC ON)
set (REQUIRED_QT_VERSION "5.3.0")
find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Quick Gui Sql Qml Svg)

set(nowdock_SRCS
    nowdockplugin.cpp
    panelwindow.cpp
)
    
add_library(nowdock SHARED ${nowdock_SRCS})

target_link_libraries(nowdock
        Qt5::Quick
        Qt5::Qml
)

install(TARGETS nowdock DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/nowdock)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/nowdock)
