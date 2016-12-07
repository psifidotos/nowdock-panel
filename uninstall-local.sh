#!/bin/bash
#Author: Michail Vourlakos
#Summary: Installation script for Now Dock Panel
#This script was written and tested on openSuSe Leap 42.1

plasmapkg2 -r org.kde.store.nowdock.panel
plasmapkg2 -t layout-template -r org.kde.store.nowdock.defaultPanel
plasmapkg2 -t layout-template -r org.kde.store.nowdock.emptyPanel
