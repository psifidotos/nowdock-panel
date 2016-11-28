add_subdirectory(org.kde.store.nowdock.defaultPanel)
add_subdirectory(org.kde.store.nowdock.emptyPanel)

plasma_install_package(../build/layout-templates/org.kde.store.nowdock.defaultPanel/release org.kde.store.nowdock.defaultPanel layout-templates layout-template) 

plasma_install_package(../build/layout-templates/org.kde.store.nowdock.emptyPanel/release org.kde.store.nowdock.emptyPanel layout-templates layout-template) 
#plasma_install_package(org.kde.store.nowdock.defaultPanel org.kde.store.nowdock.defaultPanel layout-templates layout-template)
#plasma_install_package(org.kde.store.nowdock.emptyPanel org.kde.store.nowdock.emptyPanel layout-templates layout-template) 
