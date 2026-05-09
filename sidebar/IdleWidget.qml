import QtQuick
import Quickshell
import "../"

SidebarWidget {
  id: root
  // Waybar idle_inhibitor: border-bottom: 1px dashed alpha(@color10, 1); background: alpha(@color2, 0.7)
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  borderColor: Qt.rgba(Theme.c(10).r, Theme.c(10).g, Theme.c(10).b, 1)
  borderStyle: 2 // dashed
  
  property bool activated: false
  
  content: Item {
    width: parent.width
    height: 30
    
    Text {
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: 20
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
