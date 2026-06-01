import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../"

SidebarWidget {
  id: root
  bgColor: "transparent"
  

  property int maxWorkspaceId: 5

  Instantiator {
    id: wsInstantiator
    model: Hyprland.workspaces
    delegate: QtObject {
      property int wsId: modelData.id
    }
    onCountChanged: root.updateMaxWorkspaceId()
    onObjectAdded: root.updateMaxWorkspaceId()
    onObjectRemoved: root.updateMaxWorkspaceId()
  }

  function updateMaxWorkspaceId() {
    let m = 5;
    for (let i = 0; i < wsInstantiator.count; i++) {
      let obj = wsInstantiator.objectAt(i);
      if (obj && obj.wsId > m) m = obj.wsId;
    }
    root.maxWorkspaceId = m;
  }

  content: Row {
    spacing: 2

    Repeater {
      model: root.maxWorkspaceId
      
      Rectangle {
        id: btn
        property int workspaceId: index + 1
        property bool isCurrent: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === workspaceId) : false
        property bool isActive: {
          for (let i = 0; i < wsInstantiator.count; i++) {
            let obj = wsInstantiator.objectAt(i);
            if (obj && obj.wsId === workspaceId) return true;
          }
          return false;
        }

        width: 24
        height: 24
        radius: 12
        
        color: "transparent"

        Rectangle {
          width: 16
          height: 16
          anchors.centerIn: parent
          radius: 8
          color: Qt.rgba(0, 0, 0, 0.3)
        }

        Text {
          anchors.centerIn: parent
          font.family: Theme.iconFont
          font.pixelSize: 18
          color: hover.hovered ? Theme.c(15) : Theme.textPrimary
          
          text: btn.isCurrent ? "radio_button_checked" : (btn.isActive ? "adjust" : "fiber_manual_record")
          opacity: hover.hovered ? 1.0 : (btn.isCurrent ? 1.0 : (btn.isActive ? 0.5 : 0.3))
        }

        HoverHandler { id: hover }
        TapHandler {
          onTapped: Hyprland.dispatch("workspace " + btn.workspaceId)
        }

        Rectangle {
          anchors.fill: parent
          radius: 12
          color: Qt.rgba(Theme.c(7).r, Theme.c(7).g, Theme.c(7).b, 0.1)
          visible: hover.hovered
        }
      }
    }
  }
}
