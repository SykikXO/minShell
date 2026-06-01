import QtQuick
import QtQuick.Layouts
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

  RowLayout {
    id: row
    width: parent.width
    height: 40
    spacing: 4

    Item { implicitWidth: 6; Layout.alignment: Qt.AlignVCenter }

    ClockWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    NotificationWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    HardwareWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }

    Item { Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter }

    WorkspacesWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }

    Item { Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter }

    NetworkWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    BluetoothWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    AudioWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    BacklightWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    IdleWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }
    BatteryWidget { Layout.preferredHeight: 30; Layout.alignment: Qt.AlignVCenter }

    Item { implicitWidth: 6; Layout.alignment: Qt.AlignVCenter }
  }
}
