import QtQuick
import Quickshell
import "../"

PanelWindow {
  id: root

  anchors {
    top: true
    left: true
    right: true
    bottom: false
  }

  implicitHeight: 40
  color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.0)

  Behavior on color { ColorAnimation { duration: 500 } }

  Item {
    anchors.fill: parent
      anchors.topMargin: 3
    Row {
      id: leftGroup
      anchors.left: parent.left
      anchors.leftMargin: 5
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5

      ClockWidget { height: 34 }
      NotificationWidget { height: 34 }
      HardwareWidget { height: 34 }
    }

    Item {
      id: centerAnchor
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: 0
      anchors.verticalCenter: parent.verticalCenter
      Row {
        id: centerGroup
        anchors.centerIn: parent
        WorkspacesWidget {
          height: 34
        }
      }
    }

    Row {
      id: rightGroup
      anchors.right: parent.right
      anchors.rightMargin: 5
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5

      NetworkWidget { height: 34 }
      BluetoothWidget { height: 34 }
      AudioWidget { height: 34 }
      BacklightWidget { height: 34 }
      IdleWidget { height: 34 }
      BatteryWidget { height: 34 }
    }
  }
}
