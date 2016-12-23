#!/bin/sh

BASEDIR=".." # root of translatable sources
PROJECT="plasma_applet_org.kde.store.nowdock.panel" # project name
PROJECTPATH="../../containment" # project path
PROJECTPATHPLASMOID="../../nowdockplasmoid" # project path
BUGADDR="https://github.com/psifidotos/nowdock-panel/" # MSGID-Bugs
WDIR="`pwd`/containment" # working dir

cd containment
intltool-merge --quiet --desktop-style . ../../containment.metadata.desktop.template "${PROJECTPATH}"/metadata.desktop.cmake
echo "metadata.desktop files for panel were updated..."

cd ../nowdockplasmoid
intltool-merge --quiet --desktop-style . ../../nowdockplasmoid.metadata.desktop.template "${PROJECTPATHPLASMOID}"/metadata.desktop.cmake
echo "metadata.desktop files for plasmoid were updated..."

