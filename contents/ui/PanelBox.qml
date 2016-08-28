import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Component{
    Item{
        id:barLine

        opacity: root.showBarLine ? 1 : 0
        parent: root
        z:0

        anchors.bottom: (plasmoid.location === PlasmaCore.Types.BottomEdge) ? parent.bottom : undefined
        anchors.top: (plasmoid.location === PlasmaCore.Types.TopEdge) ? parent.top : undefined
        anchors.left: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? parent.left : undefined
        anchors.right: (plasmoid.location === PlasmaCore.Types.RightEdge) ? parent.right : undefined

        anchors.horizontalCenter: root.isHorizontal ? parent.horizontalCenter : undefined
        anchors.verticalCenter: root.isVertical ? parent.verticalCenter : undefined

        width: root.isHorizontal ? currentLayout.width + spacing : smallSize
        height: root.isVertical ? currentLayout.height + spacing : smallSize

        property int spacing: root.iconSize / 2
        property int smallSize: Math.max(3.7*root.statesLineSize, 16)

        Behavior on opacity{
            NumberAnimation { duration: 150 }
        }

        /// plasmoid's default panel
        BorderImage{
            anchors.fill:parent
            source: "../images/panel-west.png"
            border { left:8; right:8; top:8; bottom:8 }

            opacity: (!root.useThemePanel) ? 1 : 0

            visible: (opacity == 0) ? false : true

            horizontalTileMode: BorderImage.Stretch
            verticalTileMode: BorderImage.Stretch

            Behavior on opacity{
                NumberAnimation { duration: 200 }
            }
        }


        /// item which is used as anchors for the plasma's theme
        Item{
            id:belower

            width: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? shadowsSvgItem.margins.left : shadowsSvgItem.margins.right
            height: (plasmoid.location === PlasmaCore.Types.BottomEdge)? shadowsSvgItem.margins.bottom : shadowsSvgItem.margins.top

            anchors.top: (plasmoid.location === PlasmaCore.Types.BottomEdge) ? parent.bottom : undefined
            anchors.bottom: (plasmoid.location === PlasmaCore.Types.TopEdge) ? parent.top : undefined
            anchors.right: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? parent.left : undefined
            anchors.left: (plasmoid.location === PlasmaCore.Types.RightEdge) ? parent.right : undefined
        }


        /// the current theme's panel
        PlasmaCore.FrameSvgItem{
            id: shadowsSvgItem

            anchors.bottom: (plasmoid.location === PlasmaCore.Types.BottomEdge) ? belower.bottom : undefined
            anchors.top: (plasmoid.location === PlasmaCore.Types.TopEdge) ? belower.top : undefined
            anchors.left: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? belower.left : undefined
            anchors.right: (plasmoid.location === PlasmaCore.Types.RightEdge) ? belower.right : undefined

            anchors.horizontalCenter: root.isHorizontal ? parent.horizontalCenter : undefined
            anchors.verticalCenter: root.isVertical ? parent.verticalCenter : undefined

            width: root.isVertical ? panelSize + margins.left + margins.right: parent.width
            height: root.isVertical ? parent.height : panelSize + margins.top + margins.bottom

            imagePath: "translucent/widgets/panel-background"
            prefix:"shadow"

            opacity: root.useThemePanel ? 1 : 0
            visible: (opacity == 0) ? false : true

            property int panelSize: ((plasmoid.location === PlasmaCore.Types.BottomEdge) ||
                                     (plasmoid.location === PlasmaCore.Types.TopEdge)) ?
                                        root.themePanelSize + belower.height:
                                        root.themePanelSize + belower.width

            Behavior on opacity{
                NumberAnimation { duration: 200 }
            }


            PlasmaCore.FrameSvgItem{
                anchors.margins: belower.width-1
                anchors.fill:parent
                imagePath: root.transparentPanel ? "translucent/widgets/panel-background" :
                                                   "widgets/panel-background"
            }
        }
    }
}
