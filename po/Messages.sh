#!/bin/sh

BASEDIR="../.." # root of translatable sources
PROJECT="plasma_applet_org.kde.store.nowdock.panel" # project name
PROJECTPATH="../../nowdockpanel" # project path
BUGADDR="https://github.com/psifidotos/nowdock-panel/" # MSGID-Bugs
DEFAULTLAYOUT="../../layout-templates/org.kde.store.nowdock.defaultPanel"
EMPTYLAYOUT="../../layout-templates/org.kde.store.nowdock.emptyPanel"
WDIR="`pwd`/nowdockpanel" # working dir

echo "Preparing rc files"

cd nowdockpanel

# we use simple sorting to make sure the lines do not jump around too much from system to system
find "${PROJECTPATH}" -name '*.rc' -o -name '*.ui' -o -name '*.kcfg' | sort > "${WDIR}/rcfiles.list"
xargs --arg-file="${WDIR}/rcfiles.list" extractrc > "${WDIR}/rc.cpp"

# additional string for KAboutData
# echo 'i18nc("NAME OF TRANSLATORS","Your names");' >> "${WDIR}/rc.cpp"
# echo 'i18nc("EMAIL OF TRANSLATORS","Your emails");' >> "${WDIR}/rc.cpp"

intltool-extract --quiet --type=gettext/ini ../../metadata.desktop.template
intltool-extract --quiet --type=gettext/ini ../../defaultLayout.metadata.desktop.template
intltool-extract --quiet --type=gettext/ini ../../emptyLayout.metadata.desktop.template

cat ../../metadata.desktop.template.h >> ${WDIR}/rc.cpp
cat ../../defaultLayout.metadata.desktop.template.h >> ${WDIR}/rc.cpp
cat ../../emptyLayout.metadata.desktop.template.h >> ${WDIR}/rc.cpp

rm ../../metadata.desktop.template.h
rm ../../defaultLayout.metadata.desktop.template.h
rm ../../emptyLayout.metadata.desktop.template.h


# echo "Done preparing rc files"
echo "Extracting messages"

# see above on sorting

find "${PROJECTPATH}" -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.qml' -o -name '*.qml.cmake' | sort > "${WDIR}/infiles.list"
echo "rc.cpp" >> "${WDIR}/infiles.list"

xgettext --from-code=UTF-8 -C -kde -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
	-ktr2i18n:1 -kI18N_NOOP:1 -kI18N_NOOP2:1c,2  -kN_:1 -kaliasLocale -kki18n:1 -kki18nc:1c,2 \
	-kki18np:1,2 -kki18ncp:1c,2,3 --msgid-bugs-address="${BUGADDR}" --files-from=infiles.list \
	-D "${BASEDIR}" -D "${WDIR}" -o "${PROJECT}.pot" || \
	{ echo "error while calling xgettext. aborting."; exit 1; }
echo "Done extracting messages"

echo "Merging translations"
catalogs=`find . -name '*.po'`
for cat in $catalogs; do
	echo "$cat"
	msgmerge -o "$cat.new" "$cat" "${WDIR}/${PROJECT}.pot"
	mv "$cat.new" "$cat"
done

intltool-merge --quiet --desktop-style . ../../metadata.desktop.template "${PROJECTPATH}"/metadata.desktop.cmake
intltool-merge --quiet --desktop-style . ../../defaultLayout.metadata.desktop.template "${DEFAULTLAYOUT}"/metadata.desktop.cmake
intltool-merge --quiet --desktop-style . ../../emptyLayout.metadata.desktop.template "${EMPTYLAYOUT}"/metadata.desktop.cmake

echo "Done merging translations"
echo "Cleaning up"
rm "${WDIR}/rcfiles.list"
rm "${WDIR}/infiles.list"
rm "${WDIR}/rc.cpp"
echo "Done" 
