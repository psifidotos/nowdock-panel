/*
 *  Copyright 2013 Michail Vourlakos <mvourlakos@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.plasma.plasmoid 2.0


import org.kde.nowdock 0.1 as NowDock

import "LayoutManager.js" as LayoutManager

DragDrop.DropArea {
    id: root

    //// BEGIN SIGNALS
    signal clearZoomSignal();
    signal updateIndexes();
    ////

    ////BEGIN properties
    property bool debugMode: true

    property bool automaticSize: plasmoid.configuration.automaticIconSize
    property bool immutable: plasmoid.immutable
    property bool inStartup: true
    property bool isHorizontal: plasmoid.formFactor == PlasmaCore.Types.Horizontal
    property bool isVertical: !isHorizontal
    property bool isHovered: nowDock ? ((nowDockHoveredIndex !== -1) && (layoutsContainer.hoveredIndex !== -1)) || wholeArea.containsMouse
                                     : (layoutsContainer.hoveredIndex !== -1) || wholeArea.containsMouse
    property bool onlyAddingStarup: true //is used for the initialization phase in startup where there arent removals, this variable provides a way to grow icon size
    property bool smallAutomaticIconJumps: plasmoid.configuration.smallAutomaticIconJumps
    property bool useThemePanel: noApplets === 0 ? true : plasmoid.configuration.useThemePanel


    property int animationsNeedBothAxis:0 //animations need space in both axes, e.g zooming a task
    property int animationsNeedLength: 0 // animations need length, e.g. adding a task
    property int animationsNeedThickness: 0 // animations need thickness, e.g. bouncing animation
    property int appletsAnimations: 0 //zoomed applets it is used basically on masking for magic window
    property int automaticIconSizeBasedSize: 0
    property int iconSize: (automaticIconSizeBasedSize>0 && plasmoid.immutable) ? Math.min(automaticIconSizeBasedSize, plasmoid.configuration.iconSize) :
                                                                                  plasmoid.configuration.iconSize
    property int iconStep: 8
    property int panelEdgeSpacing: iconSize / 2
    property int previousAllTasks: -1    //is used to forbit updateAutomaticIconSize when hovering
    property int realSize: iconSize + iconMargin
    property int themePanelSize: plasmoid.configuration.panelSize

    ///FIXME: I can't remember why this is needed, maybe for the anchorings!!! In order for the Double Layout to not mess the anchorings...
    property int mainLayoutPosition: !plasmoid.immutable ? 0 : (root.isVertical ? NowDock.PanelWindow.Top : NowDock.PanelWindow.Left)
    property int panelAlignment: plasmoid.configuration.panelPosition !== 10 ? plasmoid.configuration.panelPosition : mainLayoutPosition
   // property int panelAlignment: plasmoid.configuration.panelPosition


    property real zoomFactor: ( 1 + (plasmoid.configuration.zoomLevel / 20) )


    property var iconsArray: [16, 22, 32, 48, 64, 96, 128, 256]
    property var layoutManager: LayoutManager

    property Item dragOverlay
    property Item toolBox
    property Item nowDockContainer
    property Item nowDock
    property Item nowDockConfiguration

    // TO BE DELETED, if not needed: property int counter:0;

    ///BEGIN properties from nowDock
    property bool reverseLinesPosition: nowDock ? nowDock.reverseLinesPosition : false

    property int durationTime: nowDock ? nowDock.durationTime : 2
    property int nowDockHoveredIndex: nowDock ? nowDock.hoveredIndex : -1
    property int iconMargin: nowDock ? nowDock.iconMargin : 0.12 * iconSize
    property int statesLineSize: nowDock ? nowDock.statesLineSize : 0
    property int tasksCount: nowDock ? nowDock.tasksCount : 0
    ///END properties from nowDock

    width: 640
    height: 90

    Layout.preferredWidth: plasmoid.immutable ? 0 : Screen.width //on unlocked state use the maximum
    Layout.preferredHeight: plasmoid.immutable ? 0 : Screen.height

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    //// BEGIN properties in functions
    property int noApplets: {
        var count1 = 0;
        var count2 = 0;

        count1 = mainLayout.children.length;
        var tempLength = mainLayout.children.length;

        for (var i=tempLength-1; i>=0; --i) {
            var applet = mainLayout.children[i];
            if (applet && (applet === dndSpacer || applet === lastSpacer ||  applet.isInternalViewSplitter))
                count1--;
        }

        count2 = secondLayout.children.length;
        tempLength = secondLayout.children.length;

        for (var i=tempLength-1; i>=0; --i) {
            var applet = secondLayout.children[i];
            if (applet && (applet === dndSpacer || applet === lastSpacer  || applet.isInternalViewSplitter))
                count2--;
        }

        return (count1 + count2);
    }

    ///The index of user's current icon size
    property int currentIconIndex:{
        for(var i=iconsArray.length-1; i>=0; --i){
            if(iconsArray[i] === iconSize){
                return i;
            }
        }
        return 3;
    }

    //// END properties in functions

    ////////////////END properties

    //////////////////////////BEGIN states
    //user set Panel Positions
    // 0-Center, 1-Left, 2-Right, 3-Top, 4-Bottom
    states: [
        ///Left Edge
        State {
            name: "leftCenter"
            when: (plasmoid.location === PlasmaCore.Types.LeftEdge)&&(root.panelAlignment === NowDock.PanelWindow.Center)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "leftTop"
            when: (plasmoid.location === PlasmaCore.Types.LeftEdge)&&(root.panelAlignment === NowDock.PanelWindow.Top)

            AnchorChanges {
                target: mainLayout
                anchors{ top:parent.top; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "leftBottom"
            when: (plasmoid.location === PlasmaCore.Types.LeftEdge)&&(root.panelAlignment === NowDock.PanelWindow.Bottom)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:parent.bottom; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        ///Right Edge
        State {
            name: "rightCenter"
            when: (plasmoid.location === PlasmaCore.Types.RightEdge)&&(root.panelAlignment === NowDock.PanelWindow.Center)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "rightTop"
            when: (plasmoid.location === PlasmaCore.Types.RightEdge)&&(root.panelAlignment === NowDock.PanelWindow.Top)

            AnchorChanges {
                target: mainLayout
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "rightBottom"
            when: (plasmoid.location === PlasmaCore.Types.RightEdge)&&(root.panelAlignment === NowDock.PanelWindow.Bottom)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        ///Bottom Edge
        State {
            name: "bottomCenter"
            when: (plasmoid.location === PlasmaCore.Types.BottomEdge)&&(root.panelAlignment === NowDock.PanelWindow.Center)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        State {
            name: "bottomLeft"
            when: (plasmoid.location === PlasmaCore.Types.BottomEdge)&&(root.panelAlignment === NowDock.PanelWindow.Left)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:parent.bottom; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        State {
            name: "bottomRight"
            when: (plasmoid.location === PlasmaCore.Types.BottomEdge)&&(root.panelAlignment === NowDock.PanelWindow.Right)

            AnchorChanges {
                target: mainLayout
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        ///Top Edge
        State {
            name: "topCenter"
            when: (plasmoid.location === PlasmaCore.Types.TopEdge)&&(root.panelAlignment === NowDock.PanelWindow.Center)

            AnchorChanges {
                target: mainLayout
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        },
        State {
            name: "topLeft"
            when: (plasmoid.location === PlasmaCore.Types.TopEdge)&&(root.panelAlignment === NowDock.PanelWindow.Left)

            AnchorChanges {
                target: mainLayout
                anchors{ top:parent.top; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        },
        State {
            name: "topRight"
            when: (plasmoid.location === PlasmaCore.Types.TopEdge)&&(root.panelAlignment === NowDock.PanelWindow.Right)

            AnchorChanges {
                target: mainLayout
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
            }
            PropertyChanges{
                target: mainLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        }
    ]
    ////////////////END states


    //// BEGIN OF Behaviors
    Behavior on iconSize {
        NumberAnimation { duration: 200 }
    }
    //// END OF Behaviors

    //////////////START OF CONNECTIONS
    onAppletsAnimationsChanged: magicWin.updateMaskArea();

    onDragEnter: {
        if (plasmoid.immutable) {
            event.ignore();
            return;
        }

        var relevantLayout = mainLayout.mapFromItem(root, event.x, event.y);
        LayoutManager.insertAtCoordinates(dndSpacer, relevantLayout.x, relevantLayout.y)
        dndSpacer.opacity = 1;
    }

    onDragMove: {
        var relevantLayout = mainLayout.mapFromItem(root, event.x, event.y);
        LayoutManager.insertAtCoordinates(dndSpacer, relevantLayout.x, relevantLayout.y)
        dndSpacer.opacity = 1;
    }

    onDragLeave: {
        dndSpacer.opacity = 0;
        dndSpacer.parent = root;
    }

    onDrop: {
        var relevantLayout = mainLayout.mapFromItem(root, event.x, event.y);
        plasmoid.processMimeData(event.mimeData, relevantLayout.x, relevantLayout.y);
        event.accept(event.proposedAction);

        dndSpacer.opacity = 0;
        containmentSizeSyncTimer.restart();
    }

    onIsHoveredChanged: {
        if (isHovered){
            magicWin.showOnTop();
        }
    }

    onHeightChanged: {
        containmentSizeSyncTimer.restart()
        if (startupTimer.running) {
            startupTimer.restart();
        }

        //  if(isVertical)
        //    updateAutomaticIconSizeZoom();
    }

    onNowDockChanged: {
        if (nowDock) {            
            nowDock.signalAnimationsNeedBothAxis.connect(slotAnimationsNeedBothAxis);
            nowDock.signalAnimationsNeedLength.connect(slotAnimationsNeedLength);
            nowDock.signalAnimationsNeedThickness.connect(slotAnimationsNeedThickness);
        }
    }

  //  onNowDockAnimationsChanged: magicWin.updateMaskArea();

    onToolBoxChanged: {
        containmentSizeSyncTimer.restart();
        if (startupTimer.running) {
            startupTimer.restart();
        }
    }

    onWidthChanged: {
        containmentSizeSyncTimer.restart()
        if (startupTimer.running) {
            startupTimer.restart();
        }

        //  if(isHorizontal)
        //   updateAutomaticIconSizeZoom();
    }

    //  onZoomFactorChanged: updateAutomaticIconSizeZoom();
    //  onIconSizeChanged: console.log("Icon Size Changed:"+iconSize);

    Component.onCompleted: {
        //  currentLayout.isLayoutHorizontal = isHorizontal
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = mainLayout;
        LayoutManager.lastSpacer = lastSpacer;
        LayoutManager.restore();
        containmentSizeSyncTimer.restart();
        plasmoid.action("configure").visible = !plasmoid.immutable;
        plasmoid.action("configure").enabled = !plasmoid.immutable;
        updateNowDockConfiguration();

        if (!plasmoid.immutable) {
            inStartup = false;
        }
    }

    Component.onDestruction: {
        console.log("Destroying Now Dock Panel...");
    }

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    Containment.onAppletRemoved: {
        LayoutManager.removeApplet(applet);
        var flexibleFound = false;
        for (var i = 0; i < mainLayout.children.length; ++i) {
            var applet = mainLayout.children[i].applet;
            if (applet && ((root.isHorizontal && applet.Layout.fillWidth) ||
                           (!root.isHorizontal && applet.Layout.fillHeight)) &&
                    applet.visible) {
                flexibleFound = true;
                break
            }
        }
        if (!flexibleFound) {
            lastSpacer.parent = mainLayout;
        }

        LayoutManager.save();
    }

    Plasmoid.onUserConfiguringChanged: {
        if (plasmoid.immutable) {
            if (dragOverlay) {
                dragOverlay.destroy();
            }
            return;
        }

        if (plasmoid.userConfiguring) {
            for (var i = 0; i < plasmoid.applets.length; ++i) {
                plasmoid.applets[i].expanded = false;
            }
            if (!dragOverlay) {
                var component = Qt.createComponent("ConfigOverlay.qml");
                if (component.status == Component.Ready) {
                    dragOverlay = component.createObject(root);
                } else {
                    console.log("Could not create ConfigOverlay");
                    console.log(component.errorString());
                }
                component.destroy();
            } else {
                dragOverlay.visible = true;
            }
        } else {
            dragOverlay.visible = false;
            dragOverlay.destroy();
        }
    }

    Plasmoid.onFormFactorChanged: containmentSizeSyncTimer.restart();
    Plasmoid.onImmutableChanged: {
        containmentSizeSyncTimer.restart();
        plasmoid.action("configure").visible = !plasmoid.immutable;
        plasmoid.action("configure").enabled = !plasmoid.immutable;

        updateLayouts();
        updateNowDockConfiguration();

        if (!plasmoid.immutable && magicWin && magicWin.panelVisibility === NowDock.PanelWindow.AutoHide) {
            magicWin.mustBeRaised();
        }
    }
    //////////////END OF CONNECTIONS

    //////////////START OF FUNCTIONS
    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(root)

        container.applet = applet;
        applet.parent = container.appletWrapper;

        applet.anchors.fill = container.appletWrapper;

        applet.visible = true;


        // don't show applet if it choses to be hidden but still make it
        // accessible in the panelcontroller
        container.visible = Qt.binding(function() {
            return applet.status !== PlasmaCore.Types.HiddenStatus || (!plasmoid.immutable && plasmoid.userConfiguring)
        })

        addContainerInLayout(container, applet, x, y);
    }

    function addContainerInLayout(container, applet, x, y){
        // Is there a DND placeholder? Replace it!
        if (dndSpacer.parent === mainLayout) {
            LayoutManager.insertBefore(dndSpacer, container);
            dndSpacer.parent = root;
            return;
            // If the provided position is valid, use it.
        } else if (x >= 0 && y >= 0) {
            var index = LayoutManager.insertAtCoordinates(container, x , y);

            // Fall through to determining an appropriate insert position.
        } else {
            var before = null;
            container.animationsEnabled = false;

            if (lastSpacer.parent === mainLayout) {
                before = lastSpacer;
            }

            // Insert icons to the left of whatever is at the center (usually a Task Manager),
            // if it exists.
            // FIXME TODO: This is a real-world fix to produce a sensible initial position for
            // launcher icons added by launcher menu applets. The basic approach has been used
            // since Plasma 1. However, "add launcher to X" is a generic-enough concept and
            // frequent-enough occurence that we'd like to abstract it further in the future
            // and get rid of the uglyness of parties external to the containment adding applets
            // of a specific type, and the containment caring about the applet type. In a better
            // system the containment would be informed of requested launchers, and determine by
            // itself what it wants to do with that information.
            if (!startupTimer.running && applet.pluginName == "org.kde.plasma.icon") {
                var middle = mainLayout.childAt(root.width / 2, root.height / 2);

                if (middle) {
                    before = middle;
                }

                // Otherwise if lastSpacer is here, enqueue before it.
            }

            if (before) {
                LayoutManager.insertBefore(before, container);

                // Fall through to adding at the end.
            } else {
                container.parent = mainLayout;
            }

            //event compress the enable of animations
            startupTimer.restart();
        }

        //Important, removes the first children of the mainLayout after the first
        //applet has been added
        lastSpacer.parent = root;

        updateIndexes();
    }

    function addInternalViewSplitter(pos){
        if(!internalViewSplitterExists()){
            var container = appletContainerComponent.createObject(root);

            container.isInternalViewSplitter = true;
            container.visible = true;

            if(pos >=0 )
                layoutManager.insertAtIndex(container, pos);
            else
                layoutManager.insertAtIndex(container, Math.floor(mainLayout.count / 2));

            layoutManager.save();
            // addContainerInLayout(container, x, y);
        }
    }

    function checkLastSpacer() {
        lastSpacer.parent = root

        var expands = false;

        if (isHorizontal) {
            for (var container in mainLayout.children) {
                var item = mainLayout.children[container];
                if (item.Layout && item.Layout.fillWidth) {
                    expands = true;
                }
            }
        } else {
            for (var container in mainLayout.children) {
                var item = mainLayout.children[container];
                if (item.Layout && item.Layout.fillHeight) {
                    expands = true;
                }
            }
        }
        if (!expands) {
            lastSpacer.parent = mainLayout
        }
    }

    function checkLayoutsAnimatedLength() {
        if (!magicWin.isHovered && (root.animationsNeedBothAxis === 0) && (root.animationsNeedLength===0) && (root.appletsAnimations === 0)) {
            mainLayout.animatedLength = true;
        } else {
            mainLayout.animatedLength = false;
        }

        //After the last animations we must check again after a small delay in order
        //to disable the automaticSizeUpdate
        if (animatedLengthTimer.running) {
            animatedLengthTimer.restart();
        } else {
            animatedLengthTimer.start();
        }

        magicWin.updateMaskArea();
    }

    function clearZoom(){
        //console.log("Panel clear....");
        layoutsContainer.currentSpot = -1000;
        layoutsContainer.hoveredIndex = -1;
        root.clearZoomSignal();
    }

    function containsMouse(){
        var result = root.outsideContainsMouse();

        if(result)
            return true;

        if(!result && nowDock && nowDock.outsideContainsMouse()){
            layoutsContainer.hoveredIndex = nowDockContainer.index;
            return true;
        }

        if (nowDock){
            nowDock.clearZoom();
        }

        return false;
    }

    function internalViewSplitterExists(){
        for (var container in mainLayout.children) {
            var item = mainLayout.children[container];
            if(item && item.isInternalViewSplitter)
                return true;
        }
        return false;
    }

    function outsideContainsMouse(){
        var applets = mainLayout.children;

        for(var i=0; i<applets.length; ++i){
            var applet = applets[i];

            if(applet && applet.containsMouse){
                return true;
            }
        }

        ///check second layout also
        var applets = secondLayout.children;

        for(var i=0; i<applets.length; ++i){
            var applet = applets[i];

            if(applet && applet.containsMouse){
                return true;
            }
        }

        return false;
    }

    function removeInternalViewSplitter(){
        for (var container in mainLayout.children) {
            var item = mainLayout.children[container];
            if(item && item.isInternalViewSplitter)
                item.destroy();
        }

        layoutManager.save();
    }

    function sizeIsFromAutomaticMode(size){

        for(var i=iconsArray.length-1; i>=0; --i){
            if(iconsArray[i] === size){
                return true;
            }
        }

        return false;
    }

    function slotAnimationsNeedBothAxis(value) {
        if (animationsNeedBothAxis === value) {
            return;
        }

        animationsNeedBothAxis = value;
        magicWin.updateMaskArea();
    }

    function slotAnimationsNeedLength(value) {
        if (animationsNeedLength === value) {
            return;
        }

        animationsNeedLength = value;
        magicWin.updateMaskArea();
    }

    function slotAnimationsNeedThickness(value) {
        if (animationsNeedThickness === value) {
            return;
        }

        animationsNeedThickness = value;
        magicWin.updateMaskArea();
    }

    //sizeViolation variable is used when for any reason the mainLayout
    //exceeds the panel size
    function updateAutomaticIconSize(sizeViolation){
        if(((layoutsContainer.hoveredIndex == -1)
            && (nowDockHoveredIndex == -1)
            && ((smallAutomaticIconJumps && (iconSize % iconStep) == 0 ) || (!smallAutomaticIconJumps && sizeIsFromAutomaticMode(iconSize)) )
            && previousAllTasks !== layoutsContainer.allCount)
                || (sizeViolation && (iconSize % iconStep == 0))){

            //  console.log("In .... :"+previousAllTasks+" - "+currentLayout.allCount);
            //  console.log("Currect icon size :"+iconSize+"  - "+(iconSize % iconStep));

            var removedItem = previousAllTasks > layoutsContainer.allCount;

            if (removedItem)
                onlyAddingStarup = false;

            previousAllTasks = layoutsContainer.allCount;

            var layoutSize;
            var rootSize;

            if(root.isHorizontal){
                layoutSize = mainLayout.width + secondLayout.width;
                //rootSize = root.width;
                rootSize = magicWin && magicWin.visible ? magicWin.width : root.width;
            }
            else{
                layoutSize = mainLayout.height + secondLayout.height;
                //rootSize = root.height;
                rootSize = magicWin && magicWin.visible ? magicWin.height : root.height;
            }

            //compute how big is going to be layout with the new icon size
            //1+zoomFactor is used because when the signal is received
            //everything is unzoomed

            // console.log(iconSize);

            var nextIconSize

            if(smallAutomaticIconJumps)
                nextIconSize = Math.max(iconSize - iconStep, 16);
            else{
                if(currentIconIndex == 0)
                    nextIconSize = iconsArray[0];
                else
                    nextIconSize = iconsArray[currentIconIndex-1];
            }

            var dif1 = nextIconSize / iconSize;
            var limitToShrink = (1+zoomFactor)*(nextIconSize+2*dif1*iconMargin);
            var futureSizeSmaller = dif1*layoutSize + limitToShrink;
            var currentPredictedSize = layoutSize+(1+zoomFactor)*(iconSize+2*iconMargin)

            var result=0;

            if( (!removedItem || sizeViolation)
                    && currentPredictedSize>rootSize
                    && (futureSizeSmaller<rootSize|| sizeViolation)){
                result = nextIconSize;
                //   console.log("Should Decrease: "+result);
            }

            if((result===0)||(onlyAddingStarup)){

                if(smallAutomaticIconJumps){
                    nextIconSize = iconSize + iconStep;
                } else{
                    if(currentIconIndex == iconsArray.length -1)
                        nextIconSize = iconsArray[iconsArray.length -1];
                    else
                        nextIconSize = iconsArray[currentIconIndex+1];
                }

                var dif2 = nextIconSize / iconSize ;
                var limitToGrow = zoomFactor*(nextIconSize+2*dif2*iconMargin);
                var futureSize = dif2*layoutSize //- limitToGrow;

                if((removedItem || onlyAddingStarup || !sizeViolation)
                        && layoutSize<=rootSize
                        && futureSize<=rootSize) {
                    if(onlyAddingStarup) {
                        //result = automaticIconSizeBasedZoom;
                        result = plasmoid.configuration.iconSize;
                    } else {
                        result = nextIconSize;
                    }
                    //    console.log("Should Increase: "+result);
                }
            }

            if(result>0)
                automaticIconSizeBasedSize = result;
        }
    }

    function updateLayouts(){
        if(plasmoid.immutable){
            var splitter = -1;

            var totalChildren = mainLayout.children.length;
            for (var i=0; i<totalChildren; ++i) {
                var item;
                if(splitter === -1)
                    item = mainLayout.children[i];
                else{
                    item = mainLayout.children[splitter+1];
                    item.parent = secondLayout;
                }

                if(item.isInternalViewSplitter) {
                    splitter = i;
                }
            }
        }
        else{
            var totalChildren2 = secondLayout.children.length;

            for (var i=totalChildren2-1; i>=0; --i) {
                var item2 = secondLayout.children[0];
                item2.parent = mainLayout;
            }
        }

        updateIndexes();
    }

    function updateNowDockConfiguration(){
        ///BEGIN of Now Dock Configuration Panel
        if (plasmoid.immutable) {
            if (nowDockConfiguration){
                nowDockConfiguration.destroy();
            }
            return;
        }

        if (!nowDockConfiguration){
            var component = Qt.createComponent("NowDockConfiguration.qml");
            if (component.status == Component.Ready) {
                nowDockConfiguration = component.createObject(root);
            } else {
                console.log("Could not create NowDockConfiguration.qml");
                console.log(component.errorString());
            }
            component.destroy();
        }
        nowDockConfiguration.visible = true;
        ///END of Now Dock Configuration Panel
    }

    //END functions


    ///////////////BEGIN components
    Component {
        id: appletContainerComponent
        AppletItem{}
    }
    ///////////////END components

    ///////////////BEGIN UI elements
    Item {
        id: lastSpacer
        parent: mainLayout

        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle{
            anchors.fill: parent
            color: "transparent"
            border.color: "yellow"
            border.width: 1
        }
    }

    Item {
        id: dndSpacer

        property int normalSize: root.statesLineSize + root.iconSize+2*root.iconMargin

        width: normalSize
        height: normalSize

        Layout.preferredWidth: width
        Layout.preferredHeight: height
        opacity: 0

        AddWidgetVisual{}
    }

    Rectangle{
        anchors.fill: parent
        color: "yellow"
        opacity: 0.15
        visible: root.debugMode
    }

    MouseArea{
        id: wholeArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (plasmoid.immutable && magicWin && magicWin.panelVisibility === NowDock.PanelWindow.AutoHide) {
                magicWin.updateMaskArea();
                magicWin.mustBeRaised();
            } else {
                magicWin.showOnTop();
            }
        }

        onExited: {
            if (plasmoid.immutable && magicWin && !magicWin.isHovered && magicWin.panelVisibility === NowDock.PanelWindow.AutoHide) {
                hideMagicWindowInAutoHide.start();
            }
        }
    }

    MagicWindow{
        id: magicWin

        visible: false
    }

    Item{
        id: layoutsContainer

        signal updateScale(int delegateIndex, real newScale, real step)

        property bool parentMagicWinFlag: plasmoid.immutable && magicWin && !root.inStartup

        property int allCount: root.nowDock ? mainLayout.count-1+nowDock.tasksCount : mainLayout.count
        property int currentSpot: -1000
        property int hoveredIndex: -1

        x: 0
        y: 0
        width: parent.width
        height: parent.height

        Component.onCompleted: {
            if(plasmoid.immutable) {
                opacity = 0;
            } else {
                opacity = 1;
            }
        }

        onParentChanged: {
            if (magicWin && magicWin.contentItem && (parent === magicWin.contentItem)) {
                magicWin.updateMaskArea();
            }
        }

        onParentMagicWinFlagChanged: {
            if (parentMagicWinFlag) {
                opacity = 0;
                parent = magicWin.contentItem;
                magicWin.visible = true;
                magicWin.initializeSlidingInAnimation();
            } else {
                parent = root;
                magicWin.visible = false;
            }
        }

        Loader{
            anchors.fill: parent

            // FIX IT && TEST IT: it is crashing Plasma with two Now Docks one of which has only
            // task manager (small)
            //active: root.useThemePanel
            active: true

            sourceComponent: PanelBox{}
        }

        // This is the main Layout, in contrary with the others
        Grid{
            id: mainLayout

            columns: root.isVertical ? 1 : 0
            columnSpacing: 0
            flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
            rows: root.isHorizontal ? 1 : 0
            rowSpacing: 0


            Layout.preferredWidth: width
            Layout.preferredHeight: height

            property bool animatedLength: false
            property int count: children.length

            onHeightChanged: {
                if (root.isVertical && magicWin && plasmoid.immutable) {
                    checkLayoutsAnimatedLength();
                }

                if(root.isVertical && plasmoid.immutable && magicWin && magicWin.visible && !root.inStartup) {
                    if (mainLayout.height > magicWin.height)
                        updateAutomaticIconSize(true);
                    else
                        updateAutomaticIconSize(false);
                }
            }

            onWidthChanged: {
                if (root.isHorizontal && magicWin && plasmoid.immutable) {
                    checkLayoutsAnimatedLength();
                }

                if(root.isHorizontal && plasmoid.immutable && magicWin && magicWin.visible && !root.inStartup) {
                    if (mainLayout.width > magicWin.width)
                        updateAutomaticIconSize(true);
                    else
                        updateAutomaticIconSize(false);
                }
            }

        }

        Grid{
            id:secondLayout

            columns: root.isVertical ? 1 : 0
            columnSpacing: 0
            flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
            rows: root.isHorizontal ? 1 : 0
            rowSpacing: 0


            Layout.preferredWidth: width
            Layout.preferredHeight: height

           // anchors.right: parent.right
           // anchors.bottom: parent.bottom

            property int beginIndex: 100
            property int count: children.length

            states:[
                State {
                    name: "bottom"
                    when: (plasmoid.location === PlasmaCore.Types.BottomEdge)&&(plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double)

                    AnchorChanges {
                        target: secondLayout
                        anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
                    }
                    PropertyChanges{
                        target: secondLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
                    }
                },
                State {
                    name: "left"
                    when: (plasmoid.location === PlasmaCore.Types.LeftEdge)&&(plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double)

                    AnchorChanges {
                        target: secondLayout
                        anchors{ top:undefined; bottom:parent.bottom; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:undefined}
                    }
                    PropertyChanges{
                        target: secondLayout; horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
                    }
                },
                State {
                    name: "right"
                    when: (plasmoid.location === PlasmaCore.Types.RightEdge)&&(plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double)

                    AnchorChanges {
                        target: secondLayout
                        anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
                    }
                    PropertyChanges{
                        target: secondLayout; horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
                    }
                },
                State {
                    name: "top"
                    when: (plasmoid.location === PlasmaCore.Types.TopEdge)&&(plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double)

                    AnchorChanges {
                        target: secondLayout
                        anchors{ top:parent.top; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:undefined}
                    }
                    PropertyChanges{
                        target: secondLayout; horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
                    }
                }
            ]
        }
    }

    ///////////////END UI elements

    ///////////////BEGIN TIMER elements
    Timer {
        id:hideMagicWindowInAutoHide
        interval:1500
        onTriggered: {
            if (plasmoid.immutable && magicWin && !magicWin.isHovered && !wholeArea.containsMouse
                    && magicWin.panelVisibility === NowDock.PanelWindow.AutoHide) {
                magicWin.mustBeLowered();
            }

        }
    }


    Timer {
        id: animatedLengthTimer
        interval: 150
        onTriggered: {
            if (!magicWin.isHovered && (appletsAnimations === 0)
                    && (root.animationsNeedLength === 0) && (root.animationsNeedBothAxis ===0)) {
                mainLayout.animatedLength = false;
                magicWin.updateMaskArea();
            }
        }
    }

    //Timer to check if the mouse is still inside the ListView
    Timer{
        id:checkListHovered
        repeat:false;
        interval:120;

        onTriggered: {
            if(!root.containsMouse())
                root.clearZoom();
        }
    }

    Timer {
        id: containmentSizeSyncTimer
        interval: 150
        onTriggered: {
            dndSpacer.parent = root;
            //    currentLayout.x = (Qt.application.layoutDirection === Qt.RightToLeft && !plasmoid.immutable) ? toolBox.width : 0;
            //   currentLayout.y = 0
            /*   currentLayout.width = root.width - (isHorizontal && toolBox && !plasmoid.immutable ? toolBox.width : 0)
            currentLayout.height = root.height - (!isHorizontal && toolBox && !plasmoid.immutable ? toolBox.height : 0) */
            //  currentLayout.isLayoutHorizontal = isHorizontal
        }
    }

    //FIXME: I don't see other ways at the moment a way to see when the UI is REALLY ready
    Timer {
        id: startupTimer
        interval: 4000
        onTriggered: {
            for (var i = 0; i < mainLayout.children.length; ++i) {
                if ( mainLayout.children[i].hasOwnProperty('animationsEnabled') ) {
                    mainLayout.children[i].animationsEnabled = true;
                }
            }
            inStartup = false;
        }
    }

    ///////////////END TIMER elements

}
