import QtQuick

Item {
  property string label: ""
  property string style: "filled"
  property color bgColor: Theme.accent
  property int badgeSize: 16

  width: badgeSize
  height: badgeSize

  Rectangle {
    anchors.fill: parent
    radius: badgeSize / 2
    color: style === "filled" ? bgColor : "transparent"
    border.color: bgColor
    border.width: style === "filled" ? 0 : 1
    antialiasing: true
    opacity: style === "outlined" ? 0.2 : 1.0

    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: "transparent"
      border.color: bgColor
      border.width: 1
      visible: style === "outlined"
    }
  }

  Text {
    anchors.centerIn: parent
    text: label
    font.pixelSize: 10
    font.bold: true
    color: style === "filled" ? Theme.bgPrimary : bgColor
  }
}