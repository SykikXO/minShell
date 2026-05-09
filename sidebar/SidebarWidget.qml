import QtQuick
import Quickshell
import "../" // Theme

Rectangle {
  id: root
  
  property alias content: layout.children
  property color bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  property color borderColor: Qt.rgba(Theme.c(7).r, Theme.c(7).g, Theme.c(7).b, 1)
  property int borderStyle: 1 // 1: solid, 2: dashed, 3: dotted
  
  width: parent.width - 10
  height: layout.implicitHeight + 10
  anchors.horizontalCenter: parent.horizontalCenter
  
  color: bgColor
  radius: 4

  Column {
    id: layout
    anchors.centerIn: parent
    width: parent.width
    spacing: 4
  }

  // Bottom Border mimicking Waybar
  Rectangle {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 1
    color: "transparent"
    
    // To mimic dashed/dotted we can use a repeating pattern or just simple opacity
    // For simplicity, using a solid line with opacity.
    Rectangle {
      anchors.fill: parent
      color: root.borderColor
      opacity: root.borderStyle === 1 ? 1.0 : (root.borderStyle === 2 ? 0.7 : 0.4)
    }
  }

  // Hover effect
  HoverHandler {
    id: hover
  }
  
  opacity: hover.hovered ? 0.9 : 1.0
  Behavior on opacity { NumberAnimation { duration: 200 } }
}
