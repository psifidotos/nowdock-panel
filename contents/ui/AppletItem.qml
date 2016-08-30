/*
 *  Copyright 2013 Michail Vourlakos <mvourlakos@gmail.org>
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
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: container

    visible: false
    width: root.isHorizontal ? computeWidth : computeWidth + shownAppletMargin
    height: root.isVertical ?  computeHeight : computeHeight + shownAppletMargin

    property bool animationsEnabled: true
    property bool showZoomed: false
    property bool lockZoom: false

    property int animationTime: 70
    property int hoveredIndex: currentLayout.hoveredIndex
    property int index: -1
    property int appletMargin: applet && (applet.pluginName === "org.kdelook.nowdock") ? 0 : root.statesLineSize + 2
    property int maxWidth: root.isHorizontal ? root.height : root.width
    property int maxHeight: root.isHorizontal ? root.height : root.width
    property int shownAppletMargin: applet && (applet.pluginName === "org.kde.plasma.systemtray") ? appletMargin/2 : appletMargin

    //property real animationStep: root.iconSize / 8
    property real animationStep: 6
    property real computeWidth: root.isVertical ? wrapper.width :
                                                  hiddenSpacerLeft.width+wrapper.width+hiddenSpacerRight.width

    property real computeHeight: root.isVertical ? hiddenSpacerLeft.height + wrapper.height + hiddenSpacerRight.height :
                                                   wrapper.height

    property Item applet
    property Item nowDock: applet && (applet.pluginName === "org.kdelook.nowdock") ?
                               (applet.children[0] ? applet.children[0] : null) : null
    property Item appletWrapper: applet &&
                                 ((applet.pluginName === "org.kdelook.nowdock") ||
                                  (applet.pluginName === "org.kde.plasma.systemtray")) ? wrapper : wrapperContainer

    property alias containsMouse: appletMouseArea.containsMouse
    property bool canBeHovered: true

    /*onComputeHeightChanged: {
        if(index==0)
            console.log(computeHeight);
    }*/

    /// BEGIN functions
    function checkIndex(){
        index = -1;

        for(var i=0; i<currentLayout.count; ++i){
            if(currentLayout.children[i] == container){
                index = i;
                break;
            }
        }

        if(container.nowDock){
            if(index>0)
                nowDock.disableLeftSpacer = true;
            else
                nowDock.disableLeftSpacer = false;

            if(index<currentLayout.count-1)
                nowDock.disableRightSpacer = true;
            else
                nowDock.disableRightSpacer = false;
        }
    }

    //this functions gets the signal from the plasmoid, it can be used for signal items
    //outside the NowDock Plasmoid
    function interceptNowDockUpdateScale(dIndex, newScale, step){
        if(dIndex === -1){
            currentLayout.updateScale(index-1,newScale, step);
        }
        else if(dIndex === root.tasksCount){
            currentLayout.updateScale(index+1,newScale, step);
        }
    }

    function clearZoom(){
        if(wrapper)
            wrapper.zoomScale = 1;
    }

    function checkCanBeHovered(){
        if ((applet && (applet.Layout.minimumWidth > root.iconSize) && root.isHorizontal) ||
                (applet && (applet.Layout.minimumHeight > root.iconSize) && root.isVertical) ){
            canBeHovered = false;
        }
        else{
            canBeHovered = true;
        }
    }

    ///END functions

    //BEGIN connections
    onAppletChanged: {
        if (!applet) {
            destroy();
        }
    }

    onHoveredIndexChanged:{
        if ( (Math.abs(hoveredIndex-index) > 1)||(hoveredIndex == -1) )
            wrapper.zoomScale = 1;
    }

    onNowDockChanged: {
        if(container.nowDock){
            root.nowDock = container.nowDock;
            root.nowDockContainer = container;
            nowDock.nowDockPanel = root;
            nowDock.forceHidePanel = true;
            nowDock.updateScale.connect(interceptNowDockUpdateScale);
        }
    }

    onShowZoomedChanged: {
        if(showZoomed){
            var newZ = container.maxHeight / root.iconSize;
            wrapper.zoomScale = newZ;
        }
        else{
            wrapper.zoomScale = 1;
        }
    }

    Component.onCompleted: {
        checkIndex();
        root.updateIndexes.connect(checkIndex);
        root.clearZoomSignal.connect(clearZoom);
    }

    Component.onDestruction: {
        root.updateIndexes.disconnect(checkIndex);
        root.clearZoomSignal.disconnect(clearZoom);
    }

    ///END connections


    PlasmaComponents.BusyIndicator {
        z: 1000
        visible: applet && applet.busy
        running: visible
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
    }

    /*  Rectangle{
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 1
    }*/

    Flow{
        id: appletFlow
        width: container.computeWidth
        height: container.computeHeight

        anchors.rightMargin: (nowDock || (showZoomed && !plasmoid.immutable)) ||
                             (plasmoid.location !== PlasmaCore.Types.RightEdge) ? 0 : shownAppletMargin
        anchors.leftMargin: (nowDock || (showZoomed && !plasmoid.immutable)) ||
                            (plasmoid.location !== PlasmaCore.Types.LeftEdge) ? 0 : shownAppletMargin
        anchors.topMargin: (nowDock || (showZoomed && !plasmoid.immutable)) ||
                           (plasmoid.location !== PlasmaCore.Types.TopEdge)? 0 : shownAppletMargin
        anchors.bottomMargin: (nowDock || (showZoomed && !plasmoid.immutable)) ||
                              (plasmoid.location !== PlasmaCore.Types.BottomEdge) ? 0 : shownAppletMargin


        // a hidden spacer for the first element to add stability
        // IMPORTANT: hidden spacers must be tested on vertical !!!
        Item{
            id: hiddenSpacerLeft
            //we add one missing pixel from calculations
            width: root.isHorizontal ? nHiddenSize : wrapper.width
            height: root.isHorizontal ? wrapper.height : nHiddenSize

            visible: (container.index === 0)

            property real nHiddenSize: (nScale > 0) ? (root.realSize * nScale) : 0
            property real nScale: 0

            Behavior on nScale {
                NumberAnimation { duration: container.animationTime }
            }

            /*   Rectangle{
                width: 1
                height: parent.height
                x: parent.width/2
                border.width: 1
                border.color: "red"
                color: "transparent"
            } */
        }

        Item{
            id: wrapper

            width: nowDock ? ((container.showZoomed && root.isVertical) ? container.maxWidth : nowDock.tasksWidth) : scaledWidth
            height: nowDock ? ((container.showZoomed && root.isHorizontal) ? container.maxHeight : nowDock.tasksHeight ): scaledHeight

            property bool disableScaleWidth: false
            property bool disableScaleHeight: false

            property int appletMinimumWidth: applet && applet.Layout ?  applet.Layout.minimumWidth : 0
            property int appletMinimumHeight: applet && applet.Layout ? applet.Layout.minimumHeight : 0

            property real scaledWidth: zoomScaleWidth * (layoutWidth + root.iconMargin)
            property real scaledHeight: zoomScaleHeight * (layoutHeight + root.iconMargin)
            property real zoomScaleWidth: disableScaleWidth ? 1 : zoomScale
            property real zoomScaleHeight: disableScaleHeight ? 1 : zoomScale

            property int layoutWidth: {
                if(applet && (applet.Layout.minimumWidth > root.iconSize) && root.isHorizontal && (!canBeHovered)){
                    return applet.Layout.minimumWidth;
                } //it is used for plasmoids that need to scale only one axis... e.g. the Weather Plasmoid
                else if(applet
                        && ( (applet.Layout.maximumWidth < root.iconSize) || (applet.Layout.preferredWidth > root.iconSize) )
                        && root.isHorizontal
                        && !disableScaleHeight){
                    disableScaleWidth = true;
                    //this way improves performance, probably because during animation the preferred sizes update a lot
                    if((applet.Layout.maximumWidth < root.iconSize))
                        return applet.Layout.preferredWidth;
                    else if ((applet.Layout.preferredWidth > root.iconSize))
                        return applet.Layout.maximumWidth;
                }
                else{
                     return root.iconSize + moreWidth;
                }
            }

            property int layoutHeight:{
                if(applet && (applet.Layout.minimumHeight > root.iconSize) && root.isVertical && (!canBeHovered)){
                    return applet.Layout.minimumHeight;
                } //it is used for plasmoids that need to scale only one axis... e.g. the Weather Plasmoid
                else if(applet
                        && ( (applet.Layout.maximumHeight < root.iconSize) || (applet.Layout.preferredHeight > root.iconSize))
                        && root.isVertical
                        && !disableScaleWidth ){
                    disableScaleHeight = true;
                    //this way improves performance, probably because during animation the preferred sizes update a lot
                    if((applet.Layout.maximumHeight < root.iconSize))
                        return applet.Layout.maximumHeight;
                    else if ((applet.Layout.preferredHeight > root.iconSize))
                        return applet.Layout.preferredHeight;
                }
                else
                    return root.iconSize + moreHeight;
            }

            property int moreHeight: applet && (applet.pluginName === "org.kde.plasma.systemtray") && root.isHorizontal ? appletMargin : 0
            property int moreWidth: applet && (applet.pluginName === "org.kde.plasma.systemtray") && root.isVertical ? appletMargin : 0

            property real center: width / 2
            property real zoomScale: 1

            property alias index: container.index
           /* property int pHeight: applet ? applet.Layout.preferredHeight : -10

            onLayoutWidthChanged: {
                console.log("----------");
                console.log("MinW "+applet.Layout.minimumWidth);
                console.log("PW "+applet.Layout.preferredWidth);
                console.log("MaxW "+applet.Layout.maximumWidth);

                console.log("MinH "+applet.Layout.minimumHeight);
                console.log("PH "+applet.Layout.preferredHeight);
                console.log("MaxH "+applet.Layout.maximumHeight);
            }

            onPHeightChanged: {
                console.log("----------");
                console.log("MinW "+applet.Layout.minimumWidth);
                console.log("PW "+applet.Layout.preferredWidth);
                console.log("MaxW "+applet.Layout.maximumWidth);

                console.log("MinH "+applet.Layout.minimumHeight);
                console.log("PH "+applet.Layout.preferredHeight);
                console.log("MaxH "+applet.Layout.maximumHeight);
            } */

            onAppletMinimumWidthChanged: {
                if(zoomScale == 1)
                    checkCanBeHovered();
            }

            onAppletMinimumHeightChanged: {
                if(zoomScale == 1)
                    checkCanBeHovered();
            }

            Item{
                id:wrapperContainer
                width: parent.zoomScaleWidth * wrapper.layoutWidth
                height: parent.zoomScaleHeight * wrapper.layoutHeight

                anchors.centerIn: parent
            }

            BrightnessContrast{
                id:hoveredImage
                anchors.fill: wrapperContainer
                enabled: opacity != 0 ? true : false
                opacity: appletMouseArea.containsMouse ? 1 : 0

                brightness: 0.25
                source: wrapperContainer

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
            }

            /*   onHeightChanged: {
                if ((index == 1)|| (index==3)){
                    console.log("H: "+index+" ("+zoomScale+"). "+currentLayout.children[1].height+" - "+currentLayout.children[3].height+" - "+(currentLayout.children[1].height+currentLayout.children[3].height));
                }
            }

            onZoomScaleChanged:{
                if ((index == 1)|| (index==3)){
                    console.log(index+" ("+zoomScale+"). "+currentLayout.children[1].height+" - "+currentLayout.children[3].height+" - "+(currentLayout.children[1].height+currentLayout.children[3].height));
                }
            }*/

          /*  Rectangle{
              anchors.fill: parent
              color: "transparent"
              border.color: "red"
              border.width: 1
          } */

            Behavior on zoomScale {
                NumberAnimation { duration: container.animationTime }
            }

            function calculateScales( currentMousePosition ){
                var distanceFromHovered = Math.abs(index - currentLayout.hoveredIndex);

                // A new algorithm tryig to make the zoom calculation only once
                // and at the same time fixing glitches
                if ((distanceFromHovered == 0)&&
                        (currentMousePosition  > 0) ){

                    var rDistance = Math.abs(currentMousePosition  - center);

                    //check if the mouse goes right or down according to the center
                    var positiveDirection =  ((currentMousePosition  - center) >= 0 );


                    //finding the zoom center e.g. for zoom:1.7, calculates 0.35
                    var zoomCenter = (root.zoomFactor - 1) / 2

                    //computes the in the scale e.g. 0...0.35 according to the mouse distance
                    //0.35 on the edge and 0 in the center
                    var firstComputation = (rDistance / center) * zoomCenter;

                    //calculates the scaling for the neighbour tasks
                    var bigNeighbourZoom = Math.min(1 + zoomCenter + firstComputation, root.zoomFactor);
                    var smallNeighbourZoom = Math.max(1 + zoomCenter - firstComputation, 1);

                    bigNeighbourZoom = Number(bigNeighbourZoom.toFixed(2));
                    smallNeighbourZoom = Number(smallNeighbourZoom.toFixed(2));

                    var leftScale;
                    var rightScale;

                    if(positiveDirection === true){
                        rightScale = bigNeighbourZoom;
                        leftScale = smallNeighbourZoom;
                    }
                    else {
                        rightScale = smallNeighbourZoom;
                        leftScale = bigNeighbourZoom;
                    }


                    //   console.log("--------------")
                    //  console.debug(leftScale + "  " + rightScale + " " + index);
                    //activate messages to update the the neighbour scales
                    currentLayout.updateScale(index-1, leftScale, 0);
                    currentLayout.updateScale(index+1, rightScale, 0);
                    //these messages interfere when an applet is hidden, that is why I disabled them
                    //  currentLayout.updateScale(index-2, 1, 0);
                    //   currentLayout.updateScale(index+2, 1, 0);

                    //Left hiddenSpacer
                    if((index === 0 )&&(currentLayout.count > 1)){
                        hiddenSpacerLeft.nScale = leftScale - 1;
                    }

                    //Right hiddenSpacer  ///there is one more item in the currentLayout ????
                    if((index === currentLayout.count - 1 )&&(currentLayout.count>1)){
                        hiddenSpacerRight.nScale =  rightScale - 1;
                    }

                    zoomScale = root.zoomFactor;
                }

            } //scale


            function signalUpdateScale(nIndex, nScale, step){
                if(container && (container.index === nIndex)){
                    if (canBeHovered && !lockZoom && (applet.status !== PlasmaCore.Types.HiddenStatus)
                            && (index != currentLayout.hoveredIndex)){
                        if(!container.nowDock){
                            if(nScale >= 0)
                                zoomScale = nScale + step;
                            else
                                zoomScale = zoomScale + step;
                        }
                        else{
                            if(currentLayout.hoveredIndex<container.index)
                                nowDock.updateScale(0, nScale, step);
                            else if(currentLayout.hoveredIndex>container.index)
                                nowDock.updateScale(root.tasksCount-1, nScale, step);
                        }
                    }      ///if the applet is hidden must forward its scale events to its neighbours
                    else if ((applet.status === PlasmaCore.Types.HiddenStatus)){
                        if(currentLayout.hoveredIndex>index)
                            currentLayout.updateScale(index-1, nScale, step);
                        else if((currentLayout.hoveredIndex<index))
                            currentLayout.updateScale(index+1, nScale, step);
                    }
                }
            }

            Component.onCompleted: {
                currentLayout.updateScale.connect(signalUpdateScale);
            }
        }// Main task area // id:wrapper

        // a hidden spacer on the right for the last item to add stability
        Item{
            id: hiddenSpacerRight
            //we add one missing pixel from calculations
            width: root.isHorizontal ? nHiddenSize : wrapper.width
            height: root.isHorizontal ? wrapper.height : nHiddenSize

            visible: (container.index === currentLayout.count - 1)

            property real nHiddenSize: (nScale > 0) ? (root.realSize * nScale) : 0
            property real nScale: 0

            Behavior on nScale {
                NumberAnimation { duration: container.animationTime }
            }

            /*Rectangle{
                width: 1
                height: parent.height
                x:parent.width / 2
                border.width: 1
                border.color: "red"
                color: "transparent"
            }*/
        }

    }// Flow with hidden spacers inside

    MouseArea{
        id: appletMouseArea
        anchors.fill: parent
        enabled: (!nowDock)&&(canBeHovered)&&(!lockZoom)
        hoverEnabled: plasmoid.immutable && (!nowDock) && canBeHovered ? true : false
        propagateComposedEvents: true

        onContainsMouseChanged: {
            if(!containsMouse){
                hiddenSpacerLeft.nScale = 0;
                hiddenSpacerRight.nScale = 0;
            }
        }

        onEntered: {
            currentLayout.hoveredIndex = index;
            //            mouseEntered = true;
            /*       icList.mouseWasEntered(index-2, false);
                icList.mouseWasEntered(index+2, false);
                icList.mouseWasEntered(index-1, true);
                icList.mouseWasEntered(index+1, true); */
            if (root.isHorizontal){
                currentLayout.currentSpot = mouseX;
                wrapper.calculateScales(mouseX);
            }
            else{
                currentLayout.currentSpot = mouseY;
                wrapper.calculateScales(mouseY);
            }
        }

        onExited:{
            checkListHovered.start();
        }

        onPositionChanged: {
            if (root.isHorizontal){
                var step = Math.abs(currentLayout.currentSpot-mouse.x);
                if (step >= container.animationStep){
                    currentLayout.hoveredIndex = index;
                    currentLayout.currentSpot = mouse.x;

                    wrapper.calculateScales(mouse.x);
                }
            }
            else{
                var step = Math.abs(currentLayout.currentSpot-mouse.y);
                if (step >= container.animationStep){
                    currentLayout.hoveredIndex = index;
                    currentLayout.currentSpot = mouse.y;

                    wrapper.calculateScales(mouse.y);
                }
            }
            mouse.accepted = false;
        }

        onClicked: mouse.accepted = false;
    }

    //BEGIN states
    states: [
        State {
            name: "left"
            when: plasmoid.location === PlasmaCore.Types.LeftEdge

            AnchorChanges {
                target: appletFlow
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined;}
            }
        },
        State {
            name: "right"
            when: plasmoid.location === PlasmaCore.Types.RightEdge

            AnchorChanges {
                target: appletFlow
                anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right;}
            }
        },
        State {
            name: "bottom"
            when: plasmoid.location === PlasmaCore.Types.BottomEdge

            AnchorChanges {
                target: appletFlow
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined;}
            }
        },
        State {
            name: "top"
            when: plasmoid.location === PlasmaCore.Types.TopEdge

            AnchorChanges {
                target: appletFlow
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined;}
            }
        }
    ]
    //END states

}


