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

  Rectangle {
    anchors.fill: parent
    color: "transparent"

    Flickable {
      anchors.fill: parent
      contentWidth: row.width
      contentHeight: row.height
      flickableDirection: Flickable.HorizontalFlick
      clip: true

      Row {
        id: row
        height: parent.height
        spacing: 4
        leftPadding: 6
        rightPadding: 6

        ClockWidget {}
        NotificationWidget {}

        Rectangle {
          width: 1; height: 20
          color: Theme.borderColor
          anchors.verticalCenter: parent.verticalCenter
        }

        WorkspacesWidget {}

        Rectangle {
          width: 1; height: 20
          color: Theme.borderColor
          anchors.verticalCenter: parent.verticalCenter
        }

        NetworkWidget {}
        BluetoothWidget {}
        AudioWidget {}
        BacklightWidget {}
        HardwareWidget {}

        Rectangle {
          width: 1; height: 20
          color: Theme.borderColor
          anchors.verticalCenter: parent.verticalCenter
        }

        IdleWidget {}
        BatteryWidget {}
      }
    }
  }
}
