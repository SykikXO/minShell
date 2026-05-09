import QtQuick
import Quickshell
import "../" 

PanelWindow {
  id: root
  
  anchors {
    top: true
    bottom: true
    left: true
    right: false
  }

  implicitWidth: 38
  color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.0) // transparent like waybar

  // Allow Pywal transitions
  Behavior on color { ColorAnimation { duration: 500 } }

  Rectangle {
    anchors.fill: parent
    color: "transparent"

    Column {
      id: topModules
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 6
      topPadding: 6

      ClockWidget {}
      NotificationWidget {}
    }

    Flickable {
      id: upperCenterModules
      anchors.top: topModules.bottom
      anchors.bottom: lowerCenterModules.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.topMargin: 10
      anchors.bottomMargin: 10
      clip: true

      contentWidth: width
      contentHeight: wsContainer.height
      interactive: contentHeight > height

      Column {
        id: wsContainer
        width: parent.width
        spacing: 6
        y: parent.height > height ? (parent.height - height) / 2 : 0

        WorkspacesWidget {}
      }
    }

    Column {
      id: lowerCenterModules
      y: parent.height * 0.65 - height / 2
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 6

      NetworkWidget {}
      BluetoothWidget {}
      AudioWidget {}
      BacklightWidget {}
    }

    Column {
      id: bottomModules
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 6
      bottomPadding: 6

      HardwareWidget {}
      IdleWidget {}
      BatteryWidget {}
    }
  }
}
