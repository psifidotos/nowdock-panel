import QtQuick 2.1

Item{
    id: newDroppedLauncherVisual
    anchors.fill: parent

    Rectangle{
        anchors.fill: parent

        radius: units.smallSpacing

        property color tempColor: "#aa222222"
        color: tempColor
        border.width: 1
        border.color: "#ff656565"

        property int crossSize: Math.min(parent.width/2, parent.height/2)

        Rectangle{width: parent.crossSize; height: 4; radius:2; anchors.centerIn: parent; color: theme.highlightColor}
        Rectangle{width: 4; height: parent.crossSize; radius:2; anchors.centerIn: parent; color: theme.highlightColor}
    }
}
