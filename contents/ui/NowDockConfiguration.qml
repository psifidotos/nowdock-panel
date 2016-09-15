import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlAddons


Item{
    id: settingsButtonContainer
    anchors.margins: 8
    //in  Left Edge the button is appearing bigger with no reason!!!!
    anchors.horizontalCenterOffset: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? 6 : 0

    height: root.isVertical ? 75 : 40
    width: root.isVertical ? 40 : 75

    z:1000

    Rectangle{
        id:settingsButton
        anchors.fill: parent
        radius: 3
        property real backColorLuma: 0.2126*theme.backgroundColor.r + 0.7152*theme.backgroundColor.g + 0.0722*theme.backgroundColor.b
        property color backColor: backColorLuma > 0.5 ? Qt.darker(theme.backgroundColor, 1.3) : Qt.lighter(theme.backgroundColor, 1.3)
        color: activeStatus ? theme.highlightColor : backColor
        //  border.color: activeStatus ? Qt.lighter(theme.backgroundColor, 1.6) : Qt.darker(theme.textColor, 1.6)
        opacity: 0.7

        property bool activeStatus: settingsMouseArea.containsMouse || nowDockConfigurationDialog.visible

        PlasmaCore.IconItem{
            id:settingsIconItem
            //KQuickControlAddons.QIconItem{
            //   anchors.margins: 3
            //  anchors.leftMargin: (plasmoid.location === PlasmaCore.Types.LeftEdge) ? 2 : 0

            width: Math.min(0.6*settingsButtonContainer.width,0.6*settingsButtonContainer.height)
            height: width

            active: parent.activeStatus ? true : false
            enabled: true
            source: "configure"

            opacity: parent.activeStatus ? 1 : 0.85
            visible: true
        }

        MouseArea{
            id: settingsMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked:{
                if(nowDockConfigurationDialog.visible)
                    nowDockConfigurationDialog.visible = false;
                else{
                    nowDockConfigurationDialog.visible = true;
                    nowDockConfigurationDialog.raise();
                }
            }
        }
    }

    DropShadow {
        id:shadowButton
        anchors.fill: settingsButton
        radius:3
        samples: 6
        color: "#cc080808"
        source: settingsButton
        verticalOffset: 1
    }

    states: [
        ///Left Edge
        State {
            name: "left"
            when: (plasmoid.location === PlasmaCore.Types.LeftEdge)

            AnchorChanges {
                target: settingsButtonContainer
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.right; verticalCenter:undefined}
            }
            AnchorChanges {
                target: settingsIconItem
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined;
                    horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }

        },
        State {
            name: "right"
            when: (plasmoid.location === PlasmaCore.Types.RightEdge)

            AnchorChanges {
                target: settingsButtonContainer
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.left; verticalCenter:undefined}
            }
            AnchorChanges {
                target: settingsIconItem
                anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right;
                    horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
        },
        State {
            name: "bottom"
            when: (plasmoid.location === PlasmaCore.Types.BottomEdge)

            AnchorChanges {
                target: settingsButtonContainer
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.top}
            }
            AnchorChanges {
                target: settingsIconItem
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined;
                    horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        },
        State {
            name: "top"
            when: (plasmoid.location === PlasmaCore.Types.TopEdge)

            AnchorChanges {
                target: settingsButtonContainer
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.bottom}
            }
            AnchorChanges {
                target: settingsIconItem
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined;
                    horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        }
    ]

    /////BEGIN Now Dock Configuration Dialog///////
    PlasmaCore.Dialog{
        id: nowDockConfigurationDialog
        hideOnWindowDeactivate: true

        type: PlasmaCore.Dialog.Tooltip
        flags: Qt.WindowStaysOnTopHint
        location: plasmoid.location

        visualParent: settingsIconItem
        visible: false

        mainItem:Item{
            enabled: true
            width: 400
            height: mainColumn.height+10

            Column{
                id:mainColumn
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 1.3*theme.defaultFont.pointSize
                width: parent.width - 10

                Column{
                    width:parent.width
                    spacing: 0.8*theme.defaultFont.pointSize
                    PlasmaComponents.Label{
                        text:"Applets Alignment"
                        font.pointSize: 1.5 * theme.defaultFont.pointSize
                    }

                    //user set Panel Positions
                    // 0-Center, 1-Left, 2-Right, 3-Top, 4-Bottom
                    Flow{
                        width: parent.width
                        spacing: 2

                        property bool inStartup: true
                        property int panelPosition: plasmoid.configuration.panelPosition


                        function updatePanelPositionVisual(){
                            if((panelPosition == 1)||(panelPosition == 3)){
                                firstPosition.checked = true;
                                centerPosition.checked = false;
                                lastPosition.checked = false;
                            }
                            else if(panelPosition == 0){
                                firstPosition.checked = false;
                                centerPosition.checked = true;
                                lastPosition.checked = false;
                            }
                            else if((panelPosition == 2)||(panelPosition == 4)){
                                firstPosition.checked = false;
                                centerPosition.checked = false;
                                lastPosition.checked = true;
                            }
                        }

                        onPanelPositionChanged: updatePanelPositionVisual();

                        Component.onCompleted: {
                            updatePanelPositionVisual();
                            inStartup = false;
                        }

                        PlasmaComponents.Button{
                            id: firstPosition
                            checkable: true
                            text: root.isVertical ? "Top" : "Left"
                            width: parent.width

                            onCheckedChanged: {
                                if(checked && !parent.inStartup){
                                    if(root.isVertical)
                                        plasmoid.configuration.panelPosition = 3
                                    else
                                        plasmoid.configuration.panelPosition = 1
                                }
                            }
                            onClicked: checked=true;
                        }
                        PlasmaComponents.Button{
                            id: centerPosition
                            checkable: true
                            text: "Center"
                            width: parent.width

                            onCheckedChanged: {
                                if(checked && !parent.inStartup){
                                    plasmoid.configuration.panelPosition = 0
                                }
                            }
                            onClicked: checked=true;
                        }
                        PlasmaComponents.Button{
                            id: lastPosition
                            checkable: true
                            text: root.isVertical ? "Bottom" : "Right"
                            width: parent.width

                            onCheckedChanged: {
                                if(checked && !parent.inStartup){
                                    if(root.isVertical)
                                        plasmoid.configuration.panelPosition = 4
                                    else
                                        plasmoid.configuration.panelPosition = 2
                                }
                            }
                            onClicked: checked=true;
                        }
                    }
                }

                Column{
                    width: parent.width
                    spacing: 0.8*theme.defaultFont.pointSize
                    PlasmaComponents.Label{
                        text:"Zoom On Hover"
                        font.pointSize: 1.5 * theme.defaultFont.pointSize
                    }

                    RowLayout{
                        width: parent.width

                        PlasmaComponents.Button{
                            text:"-"

                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            onClicked: zoomSlider.value -= 0.05
                        }

                        PlasmaComponents.Slider{
                            id:zoomSlider

                            valueIndicatorText: "Zoom Factor"
                            valueIndicatorVisible: true

                            minimumValue: 1
                            maximumValue: 2

                            stepSize: 0.05

                            Layout.fillWidth:true

                            property bool inStartup:true

                            Component.onCompleted: {
                                value = Number(1 + plasmoid.configuration.zoomLevel/20).toFixed(2)
                                inStartup = false;
                                //  console.log("Slider:"+value);
                            }

                            onValueChanged:{
                                if(!inStartup){
                                    var result = Math.round((value - 1)*20)
                                    plasmoid.configuration.zoomLevel = result
                                    //    console.log("Store:"+result);
                                }
                            }
                        }

                        PlasmaComponents.Button{
                            text:"+"

                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            onClicked: zoomSlider.value += 0.05
                        }

                        PlasmaComponents.Label{
                            enabled: showBackground.checked
                            text: " "+Number(zoomSlider.value).toFixed(2)
                        }

                    }
                }


                Column{
                    width: parent.width
                    spacing: 0.8*theme.defaultFont.pointSize
                    PlasmaComponents.Label{
                        text:"Background"
                        font.pointSize: 1.5 * theme.defaultFont.pointSize
                    }

                    PlasmaComponents.CheckBox{
                        id: showBackground
                        text:"Show Panel Background"

                        property bool inStartup: true
                        onCheckedChanged:{
                            if(!inStartup)
                                plasmoid.configuration.useThemePanel = checked;
                        }

                        Component.onCompleted: {
                            checked = plasmoid.configuration.useThemePanel;
                            inStartup = false;
                        }
                    }

                    RowLayout{
                        width: parent.width

                        PlasmaComponents.Button{
                            enabled: showBackground.checked
                            text:"-"

                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            onClicked: panelSizeSlider.value -= 2
                        }

                        PlasmaComponents.Slider{
                            id:panelSizeSlider
                            enabled: showBackground.checked
                            valueIndicatorText: "Size"
                            valueIndicatorVisible: true

                            minimumValue: 0
                            maximumValue: 256

                            stepSize: 2

                            Layout.fillWidth:true

                            property bool inStartup: true

                            Component.onCompleted: {
                                value = plasmoid.configuration.panelSize
                                inStartup = false;
                            }

                            onValueChanged: {
                                if(!inStartup)
                                    plasmoid.configuration.panelSize = value;
                            }
                        }

                        PlasmaComponents.Button{
                            enabled: showBackground.checked
                            text:"+"

                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            onClicked: panelSizeSlider.value += 2
                        }


                        PlasmaComponents.Label{
                            enabled: showBackground.checked
                            text: panelSizeSlider.value + " px."
                        }

                    }
                }

                Column{
                    width:parent.width
                    spacing: 0.8*theme.defaultFont.pointSize

                    PlasmaComponents.Label{
                        text:"Applets Size"
                        font.pointSize: 1.5 * theme.defaultFont.pointSize
                    }

                    Flow{
                        id:iconsFlow
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        spacing: 2

                        property int buttonSize: (width/3) -2
                        property int checkedButton: -1

                        onCheckedButtonChanged:
                        {
                            for(var i=0; i<children.length; ++i)
                                if(i != checkedButton )
                                    children[i].checked = false;
                                else
                                    children[i].checked = true;

                            if (children[0].checked)
                                plasmoid.configuration.automaticIconSize = true;
                            else{
                                var realValue = 48;
                                switch(checkedButton){
                                case 1:
                                    realValue = 16;
                                    break;
                                case 2:
                                    realValue = 22;
                                    break;
                                case 3:
                                    realValue = 32;
                                    break;
                                case 4:
                                    realValue = 48;
                                    break;
                                case 5:
                                    realValue = 64;
                                    break;
                                case 6:
                                    realValue = 96;
                                    break;
                                case 7:
                                    realValue = 128;
                                    break;
                                case 8:
                                    realValue = 256;
                                    break;
                                default:
                                    realValue = 64;
                                    break
                                }
                                plasmoid.configuration.iconSize = realValue;
                                plasmoid.configuration.automaticIconSize = false;
                            }
                            // console.log("Pressed Stored:"+realValue);
                            // console.log("Pressed:"+checkedButton);
                        }

                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "Automatic"
                            onClicked: parent.checkedButton=0;
                        }

                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "16px."
                            onClicked: parent.checkedButton=1;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "22px."
                            onClicked: parent.checkedButton=2;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "32px."
                            onClicked: parent.checkedButton=3;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            checked: true
                            text: "48px."
                            onClicked: parent.checkedButton=4;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "64px."
                            onClicked: parent.checkedButton=5;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "96px."
                            onClicked: parent.checkedButton=6;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "128px."
                            onClicked: parent.checkedButton=7;
                        }
                        PlasmaComponents.Button{
                            width: parent.buttonSize
                            checkable: true
                            text: "256px."
                            onClicked: parent.checkedButton=8;
                        }

                        Component.onCompleted: {
                            //    console.log("From Store:"+plasmoid.configuration.iconSize);
                            if(plasmoid.configuration.automaticIconSize)
                                iconsFlow.checkedButton = 0;
                            else{
                                switch (plasmoid.configuration.iconSize){
                                case 16:
                                    iconsFlow.checkedButton = 1;
                                    break;
                                case 22:
                                    iconsFlow.checkedButton = 2;
                                    break;
                                case 32:
                                    iconsFlow.checkedButton = 3;
                                    break;
                                case 48:
                                    iconsFlow.checkedButton = 4;
                                    break;
                                case 64:
                                    iconsFlow.checkedButton = 5;
                                    break;
                                case 96:
                                    iconsFlow.checkedButton = 6;
                                    break;
                                case 128:
                                    iconsFlow.checkedButton = 7;
                                    break;
                                case 256:
                                    iconsFlow.checkedButton = 8;
                                    break;
                                default:
                                    iconsFlow.checkedButton = 5;
                                    break
                                }
                            }

                        }


                    } //end of Flow

                    PlasmaComponents.CheckBox{
                        id: smallJumpsChk
                        text:"Small steps for icon sizes in automatic modes"

                        property bool inStartup: true

                        onCheckedChanged:{
                            if(!inStartup)
                                plasmoid.configuration.smallAutomaticIconJumps = checked;
                        }

                        Component.onCompleted: {
                            checked = plasmoid.configuration.smallAutomaticIconJumps;
                            inStartup = false;
                        }
                    }
                }

            }
        }
    }

    /// Now Dock Configuration Dialog///////
}
