import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"
import "../components"
import "../window"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)

  BluetoothBackend { id: bt }

  property bool isConnected: bt.connected
  property string headsetBattery: ""

  property string deviceName: {
    if (!bt.powered) return "Bluetooth Off"
    if (!bt.connected) return "Disconnected"
    let name = bt.connectedDeviceName || "Unknown Device"
    if (headsetBattery !== "") {
      return name + " (" + headsetBattery + ")"
    }
    return name
  }

  Process {
    id: battProc
    command: ["bash", "-c", "upower -e | grep 'headset' | xargs -I {} upower -i {} | awk '/percentage:/{print $2}'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        root.headsetBattery = this.text.trim();
      }
    }
  }

  Timer {
    interval: hover.hovered ? 3000 : 5000
    running: true
    repeat: true
    onTriggered: battProc.running = true
  }

  content: Item {
    width: childrenRect.width
    height: childrenRect.height

    Text {
      id: icon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: Theme.sizeIcon
      font.bold: true
      color: root.isConnected ? (hover.hovered ? Theme.c(15) : Theme.textPrimary) : Theme.c(1)
      text: !bt.powered ? "bluetooth_disabled" : (root.isConnected ? "bluetooth_connected" : "bluetooth")
    }

    HoverHandler { id: hover }

    TapHandler {
      onTapped: proc.running = true
    }

    Process {
      id: proc
      command: ["qs", "ipc", "call", "shell", "bluetooth"]
    }

    SidebarTooltip {
      visible: hover.hovered
      text: root.deviceName
      targetItem: icon
    }
  }
}
