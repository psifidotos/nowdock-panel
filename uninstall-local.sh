#!/bin/bash
#Author: Michail Vourlakos
#Summary: Installation script for Now Dock Panel
#This script was written and tested on openSuSe Leap 42.1

cd nowdockpanel
plasmapkg2 -r .
cd ../layout-templates/org.kde.store.nowdock.defaultPanel
plasmapkg2 -t layout-template -r . 
