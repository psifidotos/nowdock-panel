import QtQuick 2.1

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.taskmanager 0.1 as TaskManager

import org.kde.nowdock 0.1 as NowDock

NowDock.PanelWindow{
    id: window

    property bool inStartup: root.inStartup
    property bool normalState : (root.nowDockHoveredIndex === -1) && (layoutsContainer.hoveredIndex === -1)
                                && (root.appletsAnimations === 0)
                                && (root.animationsNeedBothAxis === 0) && (root.animationsNeedLength === 0)
                                && (!mainLayout.animatedLength)


    property int animationSpeed: root.durationTime * 1.2 * units.longDuration
    property int length: root.isVertical ? screenGeometry.height : screenGeometry.width

    property int thicknessAutoHidden: 8
    property int thicknessMid: root.statesLineSize + (1 + (0.65 * (root.zoomFactor-1)))*(root.iconSize+root.iconMargin) //needed in some animations
    property int thicknessNormal: root.statesLineSize + root.iconSize + root.iconMargin + 1
    property int thicknessZoom: root.statesLineSize + ((root.iconSize+root.iconMargin) * root.zoomFactor) + 2

    childrenLength: root.isHorizontal ? mainLayout.width : mainLayout.height
    immutable: plasmoid.immutable
    location: plasmoid.location
    panelVisibility: plasmoid.configuration.panelVisibility

    /* x: {
        if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            return screenGeometry.x + (screenGeometry.width - thickness);
        } else {
            return screenGeometry.x;
        }
    }

    y: {
        if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
            return screenGeometry.y + (screenGeometry.height - thickness);
        } else {
            return screenGeometry.y;
        }
    }*/

    width: root.isHorizontal ? length : thicknessZoom
    height: root.isHorizontal ? thicknessZoom : length


    onImmutableChanged: updateMaskArea();

    onInStartupChanged: {
        if (!inStartup) {
            delayAnimationTimer.start();
        }
    }

    onIsHoveredChanged: {
        if(isHovered) {
            //stop parent window timer for auto hiding
            if (panelVisibility === NowDock.PanelWindow.AutoHide) {
                if(hideMagicWindowInAutoHide.forcedDisableHiding) {
                    hideMagicWindowInAutoHide.forcedDisableHiding = false;
                    window.disableHiding = false;
                }

                hideMagicWindowInAutoHide.stop();
            }

            if (delayerTimer.running) {
                delayerTimer.stop();
            }

            updateMaskArea();
        } else {
            // initialize the zoom
            delayerTimer.start();
        }
    }

    onMustBeRaised: {
        if (panelVisibility === NowDock.PanelWindow.AutoHide) {
            slidingAnimationAutoHiddenIn.init();
        } else {
            slidingAnimation.init(true);
        }
    }

    onMustBeLowered: {
        if (panelVisibility === NowDock.PanelWindow.AutoHide) {
            slidingAnimationAutoHiddenOut.init();
        } else {
            slidingAnimation.init(false);
        }
    }

    onNormalStateChanged: {
        if(normalState && nowDock) {
            nowDock.publishTasksGeometries();
        }
    }

    onPanelVisibilityChanged: {
        if (panelVisibility === NowDock.PanelWindow.AutoHide) {
            visible = true;
        } else {
            isAutoHidden = false;
        }
    }

    onVisibleChanged:{
        if (visible) {  //shrink the parent panel window
            initialize();
        }
    }

    function initializeSlidingInAnimation() {
        // Hide in Startup in order to show the contents with beautiful sliding animation
        var hiddenSpace;

        if ((location===PlasmaCore.Types.LeftEdge)||(location===PlasmaCore.Types.TopEdge)) {
            hiddenSpace = -thicknessNormal;
        } else {
            hiddenSpace = thicknessNormal;
        }

        if (root.isVertical) {
            layoutsContainer.x = hiddenSpace;
        } else {
            layoutsContainer.y = hiddenSpace;
        }

        layoutsContainer.opacity = 1;
        visible = true;

        if (!inStartup) {
            delayAnimationTimer.start();
        }
    }

    function updateMaskArea() {
        var localX = 0;
        var localY = 0;

        /* var normalState = (root.nowDockHoveredIndex === -1) && (layoutsContainer.hoveredIndex === -1)
                && (root.appletsAnimations === 0)
                && (root.animationsNeedBothAxis === 0) && (root.animationsNeedLength === 0)
                && (!mainLayout.animatedLength)*/

        // debug maskArea criteria
        //console.log(root.nowDockHoveredIndex + ", " + layoutsContainer.hoveredIndex + ", "
        //         + root.appletsAnimations+ ", "
        //         + root.animationsNeedBothAxis + ", " + root.animationsNeedLength + ", " + root.animationsNeedThickness +", "
        //         + mainLayout.animatedLength);

        var tempLength = root.isHorizontal ? width : height;
        var tempThickness = root.isHorizontal ? height : width;

        var space = root.panelEdgeSpacing + 6;

        if (normalState) {
            //count panel length
            if(root.isHorizontal) {
                tempLength = plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double ? screenGeometry.width : mainLayout.width + space;
            } else {
                tempLength = plasmoid.configuration.panelPosition === NowDock.PanelWindow.Double ? screenGeometry.height : mainLayout.height + space;
            }

            tempThickness = thicknessNormal;

            if (root.animationsNeedThickness > 0) {
                tempThickness = thicknessMid;
            }

            if (window.isAutoHidden && (panelVisibility === NowDock.PanelWindow.AutoHide)) {
                tempThickness = thicknessAutoHidden;
            }

            if (!immutable) {
                tempThickness = 2;
            }

            //configure x,y based on plasmoid position and root.panelAlignment(Alignment)
            if ((plasmoid.location === PlasmaCore.Types.BottomEdge) || (plasmoid.location === PlasmaCore.Types.TopEdge)) {
                if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
                    localY = window.height - tempThickness;
                } else if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                    localY = 0;
                }

                if (root.panelAlignment === NowDock.PanelWindow.Left) {
                    localX = 0;
                } else if (root.panelAlignment === NowDock.PanelWindow.Center) {
                    localX = (window.width/2) - (mainLayout.width/2) - (space/2);
                } else if (root.panelAlignment === NowDock.PanelWindow.Right) {
                    localX = window.width - mainLayout.width - (space/2);
                }
            } else if ((plasmoid.location === PlasmaCore.Types.LeftEdge) || (plasmoid.location === PlasmaCore.Types.RightEdge)){
                if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    localX = 0;
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    localX = window.width - tempThickness;
                }

                if (root.panelAlignment === NowDock.PanelWindow.Top) {
                    localY = 0;
                } else if (root.panelAlignment === NowDock.PanelWindow.Center) {
                    localY = (window.height/2) - (mainLayout.height/2) - (space/2);
                } else if (root.panelAlignment === NowDock.PanelWindow.Bottom) {
                    localY = window.height - mainLayout.height - (space/2);
                }
            }
        } else {
            if(root.isHorizontal)
                tempLength = screenGeometry.width;
            else
                tempLength = screenGeometry.height;

            //grow only on length and not thickness
            if(mainLayout.animatedLength) {
                tempThickness = thicknessNormal;

                if (root.animationsNeedThickness > 0) {
                    tempThickness = thicknessMid;
                }

                //configure the x,y position based on thickness
                if(plasmoid.location === PlasmaCore.Types.RightEdge)
                    localX = window.width - tempThickness;
                else if(plasmoid.location === PlasmaCore.Types.BottomEdge)
                    localY = window.height - tempThickness;
            } else{
                //use all thickness space
                tempThickness = thicknessZoom;
            }
        }

        var maskLength = maskArea.width; //in Horizontal
        if (root.isVertical) {
            maskLength = maskArea.height;
        }

        var maskThickness = maskArea.height; //in Horizontal
        if (root.isVertical) {
            maskThickness = maskArea.width;
        }

        // console.log("Not updating mask...");
        if( maskArea.x !== localX || maskArea.y !== localY
                || maskLength !== tempLength || maskThickness !== tempThickness) {

            // console.log("Updating mask...");
            var newMaskArea = Qt.rect(-1,-1,0,0);
            newMaskArea.x = localX;
            newMaskArea.y = localY;

            if (isHorizontal) {
                newMaskArea.width = tempLength;
                newMaskArea.height = tempThickness;
            } else {
                newMaskArea.width = tempThickness;
                newMaskArea.height = tempLength;
            }

            maskArea = newMaskArea;
        }

    }

    Rectangle{
        id: windowBackground
        anchors.fill: parent
        border.color: "red"
        border.width: 1
        color: "transparent"

        visible: root.debugMode
    }

    Rectangle{
        x: maskArea.x
        y: maskArea.y
        height: maskArea.height
        width: maskArea.width

        border.color: "green"
        border.width: 1
        color: "transparent"

        visible: root.debugMode
    }

    /***Hiding/Showing Animations*****/

    SequentialAnimation{
        id: slidingAnimation

        property bool inHalf: false
        property bool raiseFlag: false

        SequentialAnimation{
            PropertyAnimation {
                target: layoutsContainer
                property: root.isVertical ? "x" : "y"
                to: ((location===PlasmaCore.Types.LeftEdge)||(location===PlasmaCore.Types.TopEdge)) ? -thicknessNormal : thicknessNormal
                duration: window.animationSpeed
                easing.type: Easing.OutQuad
            }

            PropertyAnimation {
                target: slidingAnimation
                property: "inHalf"
                to: true
                duration: 200
            }

            PropertyAnimation {
                target: layoutsContainer
                property: root.isVertical ? "x" : "y"
                to: 0
                duration: window.animationSpeed
                easing.type: Easing.OutQuad
            }
        }

        onStopped: {
            inHalf = false;
            raiseFlag = false;
        }

        onInHalfChanged: {
            if (inHalf) {
                if (window.panelVisibility === NowDock.PanelWindow.LetWindowsCover) {
                    if (raiseFlag) {
                        window.showOnTop();
                    } else {
                        window.showOnBottom();
                    }
                } else {
                    if (raiseFlag) {
                        window.showOnTop();
                    } else {
                        window.showNormal();
                    }
                }
            }
        }

        function init(raise) {
            if(window.visible) {
                raiseFlag = raise;
                start();
            }
        }
    }
    //////////////// Auto Hide Animations - Slide In - Out
    SequentialAnimation{
        id: slidingAnimationAutoHiddenOut

        PropertyAnimation {
            target: layoutsContainer
            property: root.isVertical ? "x" : "y"
            to: ((location===PlasmaCore.Types.LeftEdge)||(location===PlasmaCore.Types.TopEdge)) ? -thicknessNormal : thicknessNormal
            duration: window.animationSpeed
            easing.type: Easing.OutQuad
        }

        onStopped: {
            window.isAutoHidden = true;
            updateMaskArea();
        }

        function init() {
            start();
        }
    }

    SequentialAnimation{
        id: slidingAnimationAutoHiddenIn

        PropertyAnimation {
            target: layoutsContainer
            property: root.isVertical ? "x" : "y"
            to: 0
            duration: window.animationSpeed
            easing.type: Easing.OutQuad
        }

        function init() {
            window.isAutoHidden = false;
            updateMaskArea();
            start();
        }
    }

    ///////////// External Connections //////
    TaskManager.ActivityInfo {
        onCurrentActivityChanged: {
            window.disableHiding = true;

            if (window.isAutoHidden) {
                window.mustBeRaised();
            }

            hideMagicWindowInAutoHide.forcedDisableHiding = true;
            hideMagicWindowInAutoHide.start();
        }
    }

    ////////////// Timers //////
    //Timer to delay onLeave event
    Timer {
        id: delayerTimer
        interval: 400
        onTriggered: {
            root.clearZoom();
            if (root.nowDock) {
                nowDock.clearZoom();
            }
        }
    }

    //Timer to delay onLeave event
    Timer {
        id: delayAnimationTimer
        interval: window.inStartup ? 1000 : 500
        onTriggered: {
            layoutsContainer.opacity = 1;
            if (panelVisibility !== NowDock.PanelWindow.AutoHide) {
                slidingAnimation.init(true);
            } else {
                slidingAnimationAutoHiddenIn.init();
            }
        }
    }
}
