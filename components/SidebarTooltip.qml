import QtQuick
import Quickshell
import "../"

PopupWindow {
  id: root

  property string text: ""
  property color textColor: Theme.textPrimary
  property string fontFamily: Theme.barFont
  property int fontPixelSize: 16
  property Item targetItem: parent

  color: "transparent"
  implicitWidth: contentRect.implicitWidth
  implicitHeight: contentRect.implicitHeight

  anchor {
    item: targetItem
    edges: Qt.BottomEdge
    margins.top: 4
  }

  Rectangle {
    id: contentRect
    color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
    border.color: Theme.c(6)
    border.width: 1
    radius: 4
    implicitWidth: textItem.implicitWidth + 20
    implicitHeight: textItem.implicitHeight + 20

    Text {
      id: textItem
      anchors.centerIn: parent
      text: root.text
      textFormat: Text.RichText
      font.family: fontFamily
      font.pixelSize: fontPixelSize
      color: textColor
    }
  }
}
