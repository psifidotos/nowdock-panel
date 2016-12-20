project(nowdock)
set(PROJECT_VERSION "0.1")
set(PROJECT_VERSION_MAJOR 0)

set(CMAKE_CXX_STANDARD 14)

cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

set(QT_MIN_VERSION "5.6.0")
set(KF5_MIN_VERSION "5.26.0")

set(CMAKE_INSTALL_PREFIX "/usr")

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
     Quick QuickWidgets)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Plasma PlasmaQuick WindowSystem Declarative
    I18n CoreAddons XmlGui DBusAddons Notifications)


include(KDEInstallDirs)
include(KDECMakeSettings)
#include(KDECompilerSettings NO_POLICY_SCOPE)
#include(ECMPackageConfigHelpers)
include(CMakePackageConfigHelpers)
include(WriteBasicConfigVersionFile)
include(CheckIncludeFiles)
include(ECMOptionalAddSubdirectory)
include(ECMQtDeclareLoggingCategory)
include(KDEPackageAppTemplates)


set(nowdock-app_SRCS
    nowdockcorona.cpp
    nowdockview.cpp
    nowdockconfigview.cpp
    packageplugins/shell/nowdockpackage.cpp
    main.cpp
)

#add_subdirectory(packageplugins)

add_executable(nowdock ${nowdock-app_SRCS})

target_link_libraries(
    nowdock
    Qt5::Widgets
    Qt5::Quick
    Qt5::Qml
    KF5::I18n
    KF5::CoreAddons
    KF5::XmlGui
    KF5::PlasmaQuick
    KF5::Plasma
    KF5::QuickAddons
    KF5::DBusAddons    
    KF5::Notifications
)

install(TARGETS nowdock ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
#even if hidden, the desktop file is needed anyways for kdbusservice::unique
install(FILES nowdock.desktop DESTINATION ${KDE_INSTALL_APPDIR})
plasma_install_package(nowdockshell org.kde.nowdock.shell shells shell)
