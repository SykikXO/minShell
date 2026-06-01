import QtQuick
import Quickshell
import "../"

SidebarWidget {
  id: root
  
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  property bool activated: false
  
  content: Item {
    width: 34
    height: 34
    
    Text {
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: 22
      color: hover.hovered ? Theme.c(15) : (root.activated ? Theme.c(4) : Theme.textPrimary)
      text: root.activated ? "visibility" : "visibility_off"
    }
    
    HoverHandler { id: hover }
    TapHandler {
      onTapped: {
        root.activated = !root.activated;
        // In a real implementation, you would spawn a wayland-idle-inhibitor process here
        // when activated, and kill it when deactivated.
      }
    }
  }
}
