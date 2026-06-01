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

  Row {
    id: row
    height: 40
    spacing: 4

    Item { width: 6; height: 1; y: (row.height - height) / 2 }

    ClockWidget { height: 30; y: (row.height - height) / 2 }
    NotificationWidget { height: 30; y: (row.height - height) / 2 }

    Rectangle {
      width: 1; height: 20; color: Theme.borderColor
      y: (row.height - height) / 2
    }

    WorkspacesWidget { height: 30; y: (row.height - height) / 2 }

    Rectangle {
      width: 1; height: 20; color: Theme.borderColor
      y: (row.height - height) / 2
    }

    NetworkWidget { height: 30; y: (row.height - height) / 2 }
    BluetoothWidget { height: 30; y: (row.height - height) / 2 }
    AudioWidget { height: 30; y: (row.height - height) / 2 }
    BacklightWidget { height: 30; y: (row.height - height) / 2 }
    HardwareWidget { height: 30; y: (row.height - height) / 2 }

    Rectangle {
      width: 1; height: 20; color: Theme.borderColor
      y: (row.height - height) / 2
    }

    IdleWidget { height: 30; y: (row.height - height) / 2 }
    BatteryWidget { height: 30; y: (row.height - height) / 2 }

    Item { width: 6; height: 1; y: (row.height - height) / 2 }
  }
}
