import QtQuick
import Quickshell
import Quickshell.Io
import "../"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(7).r, Theme.c(7).g, Theme.c(7).b, 0.5)
  
  
  content: Item {
    width: childrenRect.width
    height: childrenRect.height
    
    Text {
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: 20
      color: hover.hovered ? Theme.c(15) : Theme.textPrimary
      text: "notifications"
    }
    HoverHandler { id: hover }
    TapHandler {
      onTapped: proc.running = true
    }
    
    Process {
      id: proc
      command: ["swaync-client", "-t", "-sw"]
    }
  }
}
