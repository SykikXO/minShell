import QtQuick
import Quickshell
import "../" // Theme

Rectangle {
  id: root
  
  property alias content: layout.children
  property color bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  width: layout.childrenRect.width + 10
  height: parent.height - 10
  anchors.verticalCenter: parent.verticalCenter
  
  color: bgColor
  radius: 4

  Column {
    id: layout
    anchors.centerIn: parent
    spacing: 4
  }

  // Hover effect
  HoverHandler {
    id: hover
  }
  
  opacity: hover.hovered ? 0.9 : 1.0
  Behavior on opacity { NumberAnimation { duration: 200 } }
}
