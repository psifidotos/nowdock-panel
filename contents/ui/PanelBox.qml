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
        }


        /// the current theme's panel
        PlasmaCore.FrameSvgItem{
            id: shadowsSvgItem

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

        //BEGIN states
        states: [
            State {
                name: "left"
                when: plasmoid.location === PlasmaCore.Types.LeftEdge

                AnchorChanges {
                    target: barLine
                    anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
                AnchorChanges {
                    target: belower
                    anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.left}
                }
                AnchorChanges {
                    target: shadowsSvgItem
                    anchors{ top:undefined; bottom:undefined; left:belower.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
            },
            State {
                name: "right"
                when: plasmoid.location === PlasmaCore.Types.RightEdge

                AnchorChanges {
                    target: barLine
                    anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
                AnchorChanges {
                    target: belower
                    anchors{ top:undefined; bottom:undefined; left:parent.right; right:undefined}
                }
                AnchorChanges {
                    target: shadowsSvgItem
                    anchors{ top:undefined; bottom:undefined; left:undefined; right:belower.right; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
            },
            State {
                name: "bottom"
                when: plasmoid.location === PlasmaCore.Types.BottomEdge

                AnchorChanges {
                    target: barLine
                    anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                }
                AnchorChanges {
                    target: belower
                    anchors{ top:parent.bottom; bottom:undefined; left:undefined; right:undefined}
                }
                AnchorChanges {
                    target: shadowsSvgItem
                    anchors{ top:undefined; bottom:belower.bottom; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                }
            },
            State {
                name: "top"
                when: plasmoid.location === PlasmaCore.Types.TopEdge

                AnchorChanges {
                    target: barLine
                    anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                }
                AnchorChanges {
                    target: belower
                    anchors{ top:undefined; bottom:parent.top; left:undefined; right:undefined}
                }
                AnchorChanges {
                    target: shadowsSvgItem
                    anchors{ top:belower.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                }
            }
        ]
        //END states
    }
}
