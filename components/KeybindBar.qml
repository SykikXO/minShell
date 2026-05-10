import QtQuick
import QtQuick.Layouts

Flow {
  id: root

  Layout.alignment: Qt.AlignHCenter
  Layout.fillWidth: true
  spacing: 12

  property var keybinds: []
  property int maxWidth: parent ? parent.width : 0

  Repeater {
    model: root.keybinds
    delegate: Row {
      spacing: 6
      Rectangle {
        color: Theme.bgSecondary
        border.color: Theme.accent
        border.width: 1
        radius: 4
        antialiasing: true
        width: kText.contentWidth + 10
        height: kText.contentHeight + 6
        Text {
          id: kText
          text: modelData.k
          font.family: Theme.monoFont
          color: Theme.accent
          font.bold: true
          anchors.centerIn: parent
        }
      }
      Text {
        text: modelData.d
        font.family: Theme.monoFont
        color: Theme.textDark
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }
}