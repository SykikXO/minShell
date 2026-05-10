import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  Layout.fillWidth: true
  Layout.alignment: Qt.AlignHCenter
  spacing: 10

  property string icon: ""
  property string title: ""
  property color titleColor: Theme.textPrimary
  property bool showPowerDot: false
  property color dotColor: Theme.accent
  property bool dotPulsing: false

  Text {
    id: headerIcon
    text: root.icon
    font.pixelSize: Theme.sizeHeaderTitle
    font.family: Theme.iconFont
    color: titleColor

    SequentialAnimation on opacity {
      running: dotPulsing
      loops: Animation.Infinite
      NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutSine }
      NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
    }
  }

  Text {
    text: root.title
    font.pixelSize: Theme.sizeHeaderTitle
    font.family: Theme.monoFont
    font.bold: true
    color: titleColor
  }

  Rectangle {
    visible: showPowerDot
    width: 10
    height: 10
    radius: 5
    Layout.alignment: Qt.AlignVCenter
    color: dotColor

    SequentialAnimation on scale {
      running: dotPulsing
      loops: Animation.Infinite
      NumberAnimation { to: 1.4; duration: 600; easing.type: Easing.InOutSine }
      NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
    }
  }

  Behavior on color { ColorAnimation { duration: 300 } }
}