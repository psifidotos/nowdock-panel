/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
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
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0 as DragDrop

import "LayoutManager.js" as LayoutManager

DragDrop.DropArea {
    id: root
    width: 640
    height: 90

    //BEGIN properties
    Layout.minimumWidth: fixedWidth > 0 ? fixedWidth : (currentLayout.Layout.minimumWidth + (isHorizontal && toolBox ? toolBox.width : 0))
    Layout.maximumWidth: fixedWidth > 0 ? fixedWidth : (currentLayout.Layout.maximumWidth + (isHorizontal && toolBox ? toolBox.width : 0))
    Layout.preferredWidth: fixedWidth > 0 ? fixedWidth : (currentLayout.Layout.preferredWidth + (isHorizontal && toolBox ? toolBox.width : 0))

    Layout.minimumHeight: fixedHeight > 0 ? fixedHeight : (currentLayout.Layout.minimumHeight + (!isHorizontal && toolBox ? toolBox.height : 0))
    Layout.maximumHeight: fixedHeight > 0 ? fixedHeight : (currentLayout.Layout.maximumHeight + (!isHorizontal && toolBox ? toolBox.height : 0))
    Layout.preferredHeight: fixedHeight > 0 ? fixedHeight : (currentLayout.Layout.preferredHeight + (!isHorizontal && toolBox? toolBox.height : 0))

    property bool isHorizontal: plasmoid.formFactor == PlasmaCore.Types.Horizontal
    property bool isVertical: !isHorizontal

    property int fixedWidth: 0
    property int fixedHeight: 0

    property var layoutManager: LayoutManager

    property Item dragOverlay
    property Item toolBox

    signal clearZoomSignal();
    signal updateIndexes();
    //END properties

    ///BEGIN properties from nowDock
    property bool showBarLine: nowDock ? nowDock.showBarLine : false
    property bool transparentPanel: nowDock ? nowDock.transparentPanel : false
    property bool useThemePanel: nowDock ? nowDock.useThemePanel : true

    property int iconSize: nowDock ? nowDock.iconSize : 48
    property int iconMargin: nowDock ? nowDock.iconMargin : 5
    property int themePanelSize: nowDock ? nowDock.themePanelSize : 16
    property int realSize: iconSize + iconMargin
    property int statesLineSize: nowDock ? nowDock.statesLineSize : 16
    property int tasksCount: nowDock ? nowDock.tasksCount : 0

    property real zoomFactor: nowDock ? nowDock.zoomFactor : 1.7

    property Item nowDock: null;

    ///END properties from nowDock
    /*  Rectangle{
        anchors.fill: parent
        color: "transparent"
        border.color: "red"
        border.width: 1
    } */

    //BEGIN functions
    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(root)

        var appletWidth = applet.width;
        var appletHeight = applet.height;
        //applet.parent = container;
        applet.parent = container.appletWrapper;
        container.applet = applet;
        //applet.anchors.fill = container;
        applet.anchors.fill = container.appletWrapper;

        applet.visible = true;

        // don't show applet if it choses to be hidden but still make it
        // accessible in the panelcontroller
        container.visible = Qt.binding(function() {
            return applet.status !== PlasmaCore.Types.HiddenStatus || (!plasmoid.immutable && plasmoid.userConfiguring)
        })

        // Is there a DND placeholder? Replace it!
        if (dndSpacer.parent === currentLayout) {
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

            if (lastSpacer.parent === currentLayout) {
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
                var middle = currentLayout.childAt(root.width / 2, root.height / 2);

                if (middle) {
                    before = middle;
                }

                // Otherwise if lastSpacer is here, enqueue before it.
            }

            if (before) {
                LayoutManager.insertBefore(before, container);

                // Fall through to adding at the end.
            } else {
                container.parent = currentLayout;
            }

            //event compress the enable of animations
            startupTimer.restart();
        }

        //if (applet.Layout.fillWidth) {
        //Important, removes the first children of the currentLayout after the first
        //applet has been added
        lastSpacer.parent = root;
        //  }

        updateIndexes();
    }


    function checkLastSpacer() {
        lastSpacer.parent = root

        var expands = false;

        if (isHorizontal) {
            for (var container in currentLayout.children) {
                var item = currentLayout.children[container];
                if (item.Layout && item.Layout.fillWidth) {
                    expands = true;
                }
            }
        } else {
            for (var container in currentLayout.children) {
                var item = currentLayout.children[container];
                if (item.Layout && item.Layout.fillHeight) {
                    expands = true;
                }
            }
        }
        if (!expands) {
            lastSpacer.parent = currentLayout
        }
    }

    function outsideContainsMouse(){
        var applets = currentLayout.children;

        for(var i=0; i<applets.length; ++i){
            var applet = applets[i];

            if(applet && applet.containsMouse){
                return true;
            }
        }

        return false;
    }

    function containsMouse(){
        var result = root.outsideContainsMouse();

        if(result)
            return true;

        if(!result && nowDock && nowDock.outsideContainsMouse()){
            return true;
        }

        if (nowDock){
            nowDock.clearZoom();
        }

        return false;
    }

    function clearZoom(){
        //console.log("Panel clear....");
        currentLayout.currentSpot = -1000;
        currentLayout.hoveredIndex = -1;
        root.clearZoomSignal();
    }

    //END functions

    //BEGIN connections
    Component.onCompleted: {
        currentLayout.isLayoutHorizontal = isHorizontal
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = currentLayout;
        LayoutManager.lastSpacer = lastSpacer;
        LayoutManager.restore();
        containmentSizeSyncTimer.restart();
        plasmoid.action("configure").visible = !plasmoid.immutable;
        plasmoid.action("configure").enabled = !plasmoid.immutable;
    }

    onDragEnter: {
        if (plasmoid.immutable) {
            event.ignore();
            return;
        }
        //during drag operations we disable panel auto resize
        if (root.isHorizontal) {
            root.fixedWidth = root.width
        } else {
            root.fixedHeight = root.height
        }
        LayoutManager.insertAtCoordinates(dndSpacer, event.x, event.y)
    }

    onDragMove: {
        LayoutManager.insertAtCoordinates(dndSpacer, event.x, event.y)
    }

    onDragLeave: {
        dndSpacer.parent = root;
        root.fixedWidth = 0;
        root.fixedHeight = 0;
    }

    onDrop: {
        plasmoid.processMimeData(event.mimeData, event.x, event.y);
        event.accept(event.proposedAction);
        root.fixedWidth = 0;
        root.fixedHeight = 0;
        containmentSizeSyncTimer.restart();
    }


    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    Containment.onAppletRemoved: {
        LayoutManager.removeApplet(applet);
        var flexibleFound = false;
        for (var i = 0; i < currentLayout.children.length; ++i) {
            var applet = currentLayout.children[i].applet;
            if (applet && ((root.isHorizontal && applet.Layout.fillWidth) ||
                           (!root.isHorizontal && applet.Layout.fillHeight)) &&
                    applet.visible) {
                flexibleFound = true;
                break
            }
        }
        if (!flexibleFound) {
            lastSpacer.parent = currentLayout;
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

        if(plasmoid.immutable){
            updateIndexes();
        }
    }

    onToolBoxChanged: {
        containmentSizeSyncTimer.restart();
        if (startupTimer.running) {
            startupTimer.restart();
        }
    }
    //END connections

    //BEGIN components
    Loader{
        active: root.showBarLine
        sourceComponent: PanelBox{}
    }

    Component {
        id: appletContainerComponent
        AppletItem{}
    }
    //END components

    //BEGIN UI elements
    Item {
        id: lastSpacer
        parent: currentLayout

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
        Layout.preferredWidth: width
        Layout.preferredHeight: height
        width: (plasmoid.formFactor == PlasmaCore.Types.Vertical) ? currentLayout.width : theme.mSize(theme.defaultFont).width * 10
        height: (plasmoid.formFactor == PlasmaCore.Types.Vertical) ?  theme.mSize(theme.defaultFont).width * 10 : currentLayout.height

        /* Rectangle{
            anchors.fill: parent
            color: "transparent"
            border.color: "blue"
            border.width: 1
        }*/
    }

    /* Rectangle{
        anchors.fill: currentLayout
        color: "transparent"
        border.color: "yellow"
        border.width: 2
    } */

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


    GridLayout {
        id: currentLayout

        rowSpacing: 0
        columnSpacing: 0

        z:4

        property bool isLayoutHorizontal
        property int count: children.length
        property int currentSpot: -1000
        property int hoveredIndex: -1

        signal updateScale(int delegateIndex, real newScale, real step)

        Layout.preferredWidth: {
            var width = 0;
            for (var i = 0; i < currentLayout.children.length; ++i) {
                if (currentLayout.children[i].Layout) {
                    width += Math.max(currentLayout.children[i].Layout.minimumWidth, currentLayout.children[i].Layout.preferredWidth);
                }
            }
            return width;
        }
        Layout.preferredHeight: {
            var height = 0;
            for (var i = 0; i < currentLayout.children.length; ++i) {
                if (currentLayout.children[i].Layout) {
                    height += Math.max(currentLayout.children[i].Layout.minimumHeight, currentLayout.children[i].Layout.preferredHeight);
                }
            }
            return height;
        }

        //Layout.preferredHeight: 140
        rows: 1
        columns: 1
        //when horizontal layout top-to-bottom, this way it will obey our limit of one row and actually lay out left to right
        flow: isHorizontal ? GridLayout.TopToBottom : GridLayout.LeftToRight
        layoutDirection: Qt.application.layoutDirection
    }

    onWidthChanged: {
        containmentSizeSyncTimer.restart()
        if (startupTimer.running) {
            startupTimer.restart();
        }
    }
    onHeightChanged: {
        containmentSizeSyncTimer.restart()
        if (startupTimer.running) {
            startupTimer.restart();
        }
    }

    Timer {
        id: containmentSizeSyncTimer
        interval: 150
        onTriggered: {
            dndSpacer.parent = root;
            currentLayout.x = (Qt.application.layoutDirection === Qt.RightToLeft && !plasmoid.immutable) ? toolBox.width : 0;
            currentLayout.y = 0
            /*   currentLayout.width = root.width - (isHorizontal && toolBox && !plasmoid.immutable ? toolBox.width : 0)
            currentLayout.height = root.height - (!isHorizontal && toolBox && !plasmoid.immutable ? toolBox.height : 0) */
            currentLayout.isLayoutHorizontal = isHorizontal
        }
    }

    //FIXME: I don't see other ways at the moment a way to see when the UI is REALLY ready
    Timer {
        id: startupTimer
        interval: 4000
        onTriggered: {
            for (var i = 0; i < currentLayout.children.length; ++i) {
                if ( currentLayout.children[i].hasOwnProperty('animationsEnabled') ) {
                    currentLayout.children[i].animationsEnabled = true;
                }
            }
        }
    }
    //END UI elements

    //BEGIN states
    states: [
        State {
            name: "left"
            when: plasmoid.location === PlasmaCore.Types.LeftEdge

            AnchorChanges {
                target: currentLayout
                anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
        },
        State {
            name: "right"
            when: plasmoid.location === PlasmaCore.Types.RightEdge

            AnchorChanges {
                target: currentLayout
                anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right; horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
        },
        State {
            name: "bottom"
            when: plasmoid.location === PlasmaCore.Types.BottomEdge

            AnchorChanges {
                target: currentLayout
                anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        },
        State {
            name: "top"
            when: plasmoid.location === PlasmaCore.Types.TopEdge

            AnchorChanges {
                target: currentLayout
                anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined; horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        }
    ]
    //END states
}
