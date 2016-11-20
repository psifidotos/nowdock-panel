import QtQuick 2.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.nowdock 0.1 as NowDock

NowDock.PanelWindow{
    id: window

    // modality: Qt.NonModal
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

    property int thickness: root.statesLineSize + (root.iconSize * root.zoomFactor) + root.iconMargin + 2
    property int length: root.isVertical ? screenHeight : screenWidth

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Rectangle{
        id: windowBackground
        anchors.fill: parent
        color: "transparent"
        border.color: "red"
        border.width: 1
    }
    Rectangle{
        x: maskArea.x
        y: maskArea.y
        height: maskArea.height
        width: maskArea.width

        color: "transparent"
        border.color: "green"
        border.width: 1
    }

    function updateMaskArea() {
        var localX = 0;
        var localY = 0;

        var normalState = (root.nowDockHoveredIndex === -1) && (layoutsContainer.hoveredIndex === -1)
                && (nowDockAnimations === 0) && (root.animations === 0)

        var tempLength = root.isHorizontal ? width : height;
        var tempThickness = root.isHorizontal ? height : width;

        var space = root.panelEdgeSpacing + root.iconSize/2;

        if (normalState) {
            //count panel length
            if(root.isHorizontal)
                tempLength = mainLayout.width + space;
            else
                tempLength = mainLayout.height + space;

            tempThickness = root.statesLineSize + root.iconSize + root.iconMargin + 5;

            //configure the thickness position
            if(root.isVertical && plasmoid.location === PlasmaCore.Types.RightEdge)
                localX = window.width - tempThickness;
            else if(root.isHorizontal && plasmoid.location === PlasmaCore.Types.BottomEdge)
                localY = window.height - tempThickness;

            //configure the length Position
            if (root.isHorizontal) {
                localX = (window.width/2) - (mainLayout.width/2) - (space/2);
            } else {
                localY = (window.height/2) - (mainLayout.height/2) - (space/2);
            }

          //  var newChoords = mainLayout.mapToItem(windowBackground,localX,localY);

            //localX = newChoords.x - space/2;
            //localY = newChoords.y - space/2;
        } else {
            if(root.isHorizontal)
                tempLength = window.width;
            else
                tempLength = window.height;

            tempThickness = height;
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
            var newMaskArea = Qt.rect(0,0,0,0);
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


}
