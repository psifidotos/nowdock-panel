import QtQuick 2.1

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.nowdock 0.1 as NowDock

NowDock.PanelWindow{
    id: window

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


    property int thickness: root.statesLineSize + (root.iconSize * root.zoomFactor) + 5
    property int length: root.isVertical ? screenHeight : screenWidth

    property int screenWidth: 1680
    property int screenHeight: 1050

    Rectangle{
        anchors.fill: parent
        color: "transparent"
        border.color: "red"
        border.width: 1
    }

}
