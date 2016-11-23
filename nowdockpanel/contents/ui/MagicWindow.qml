import QtQuick 2.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.nowdock 0.1 as NowDock

NowDock.PanelWindow{
//Window{
    id: window

    location: plasmoid.location
    panelVisibility: plasmoid.configuration.panelVisibility

    x: {
        if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            return screenWidth - thickness;
        } else {
            return 0;
        }
    }

    y: {
        if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
            return screenHeight - thickness;
        } else {
            return 0;
        }
    }

    width: root.isHorizontal ? length : thickness
    height: root.isHorizontal ? thickness : length

    property int length: root.isVertical ? screenHeight : screenWidth
    property int normalThickness: root.statesLineSize + root.iconSize + root.iconMargin + 1
    property int thickness: root.statesLineSize + ((root.iconSize+root.iconMargin) * root.zoomFactor) + 2

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    onIsHoveredChanged: {
        if(isHovered) {
            if (delayerTimer.running) {
                delayerTimer.stop();
            }

            updateMaskArea();            
        } else {
            // initialize the zoom
            delayerTimer.start();
        }
    }

    onVisibleChanged:{
        if (visible) {  //shrink the parent panel window
           initialize();  
        }
    }

    onWindowInAttentionChanged: updateMaskArea();

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

    function updateMaskArea() {
       var localX = 0;
        var localY = 0;

        var normalState = (root.nowDockHoveredIndex === -1) && (layoutsContainer.hoveredIndex === -1)
                && (root.nowDockAnimations === 0) && (root.animations === 0) && (!mainLayout.animatedLength)

        var tempLength = root.isHorizontal ? width : height;
        var tempThickness = root.isHorizontal ? height : width;

        var space = root.panelEdgeSpacing + 6;

        if (normalState) {
            //count panel length
            if(root.isHorizontal)
                tempLength = mainLayout.width + space;
            else
                tempLength = mainLayout.height + space;

            tempThickness = normalThickness;

            if(windowInAttention) {
                tempThickness = thickness - root.iconSize/2;
            }

            //configure the x,y position based on thickness
            if(plasmoid.location === PlasmaCore.Types.RightEdge)
                localX = window.width - tempThickness;
            else if(plasmoid.location === PlasmaCore.Types.BottomEdge)
                localY = window.height - tempThickness;

            //configure the x,y Position based on length
            if (root.isHorizontal) {
                localX = (window.width/2) - (mainLayout.width/2) - (space/2);
            } else {
                localY = (window.height/2) - (mainLayout.height/2) - (space/2);
            }
        } else {
          //  console.log(root.nowDockHoveredIndex + " - " + layoutsContainer.hoveredIndex + " - "
                  //      + root.nowDockAnimations+ " - " + root.animations + " - " + mainLayout.animatedLength);

            if(root.isHorizontal)
                tempLength = Screen.width;
            else
                tempLength = Screen.height;

            //grow only on length and not thickness
            if(mainLayout.animatedLength) {
                tempThickness = normalThickness;

                //configure the x,y position based on thickness
                if(plasmoid.location === PlasmaCore.Types.RightEdge)
                    localX = window.width - tempThickness;
                else if(plasmoid.location === PlasmaCore.Types.BottomEdge)
                    localY = window.height - tempThickness;
            } else{
                //use all thickness space
                tempThickness = thickness;
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

            // FIXME: For the height(thickness) and hovering we could do better...
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

    /***Hiding/Showing Animations*****/

    onMustBeRaised: slidingAnimation.init(true);
    onMustBeLowered: slidingAnimation.init(false);

    SequentialAnimation{
        id: slidingAnimation

        property int speed: root.durationTime * 1.4 * units.longDuration
        property bool inHalf: false
        property bool raiseFlag: false

        SequentialAnimation{
                PropertyAnimation {
                    target: layoutsContainer
                    property: root.isVertical ? "x" : "y"
                    to: ((location===PlasmaCore.Types.LeftEdge)||(location===PlasmaCore.Types.TopEdge)) ? -normalThickness : normalThickness
                    duration: slidingAnimation.speed
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
                    duration: slidingAnimation.speed
                    easing.type: Easing.OutQuad
                }
        }

        onStopped: {
            inHalf = false;
            raiseFlag = false;
        }

        onInHalfChanged: {
            if (inHalf) {
                if (panelVisibility === NowDock.LetWindowsCover) {
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
}
