project(nowdock)
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
set (CMAKE_CXX_STANDARD 11)

set(VERSION 0.5.88)
set(AUTHOR "Michail Vourlakos")
set(EMAIL "mvourlakos@gmail.com")
set(WEBSITE "https://store.kde.org/p/1154578/")

find_package(ECM 0.0.11 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(KF5Plasma)

FIND_PROGRAM(GETTEXT_MSGFMT_EXECUTABLE msgfmt)

IF(NOT GETTEXT_MSGFMT_EXECUTABLE)
	MESSAGE(
"------
                 NOTE: msgfmt not found. Translations will *not* be installed
------")
ELSE(NOT GETTEXT_MSGFMT_EXECUTABLE)

        SET(catalogname plasma_applet_org.kde.nowdock.containment)

        ADD_CUSTOM_TARGET(translations ALL)

        FILE(GLOB PO_FILES po/containment/*.po)

        FOREACH(_poFile ${PO_FILES})
                GET_FILENAME_COMPONENT(_poFileName ${_poFile} NAME)
                STRING(REGEX REPLACE "^${catalogname}_?" "" _langCode ${_poFileName} )
                STRING(REGEX REPLACE "\\.po$" "" _langCode ${_langCode} )

                IF( _langCode )
                        GET_FILENAME_COMPONENT(_lang ${_poFile} NAME_WE)
                        SET(_gmoFile ${CMAKE_CURRENT_BINARY_DIR}/containment/${_lang}.gmo)

                        ADD_CUSTOM_COMMAND(TARGET translations
                                COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --check -o ${_gmoFile} ${_poFile}
                                DEPENDS ${_poFile})
                        INSTALL(FILES ${_gmoFile} DESTINATION ${LOCALE_INSTALL_DIR}/${_langCode}/LC_MESSAGES/ RENAME ${catalogname}.mo)
                ENDIF( _langCode )
        ENDFOREACH(_poFile ${PO_FILES})
        
        SET(catalogname2 plasma_applet_org.kde.store.nowdock.plasmoid)
        ADD_CUSTOM_TARGET(translations2 ALL)

        FILE(GLOB PO_FILES2 po/plasmoid/*.po)
        
        FOREACH(_poFile ${PO_FILES2})
                GET_FILENAME_COMPONENT(_poFileName ${_poFile} NAME)
                STRING(REGEX REPLACE "^${catalogname2}_?" "" _langCode ${_poFileName} )
                STRING(REGEX REPLACE "\\.po$" "" _langCode ${_langCode} )

                IF( _langCode )
                        GET_FILENAME_COMPONENT(_lang ${_poFile} NAME_WE)
                        SET(_gmoFile ${CMAKE_CURRENT_BINARY_DIR}/plasmoid/${_lang}.gmo)

                        ADD_CUSTOM_COMMAND(TARGET translations2
                                COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --check -o ${_gmoFile} ${_poFile}
                                DEPENDS ${_poFile})
                        INSTALL(FILES ${_gmoFile} DESTINATION ${LOCALE_INSTALL_DIR}/${_langCode}/LC_MESSAGES/ RENAME ${catalogname2}.mo)
                ENDIF( _langCode )
        ENDFOREACH(_poFile ${PO_FILES})

ENDIF(NOT GETTEXT_MSGFMT_EXECUTABLE) 

add_subdirectory(libnowdock)
add_subdirectory(containment)
plasma_install_package(build/containment/release org.kde.nowdock.containment) 
add_subdirectory(plasmoid)
plasma_install_package(build/plasmoid/release org.kde.store.nowdock.plasmoid) 

plasma_install_package(shell org.kde.nowdock.shell shells shell)

add_subdirectory(layout-templates)
