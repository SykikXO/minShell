import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../"
import "../components"

SidebarWidget {
  id: root
  // Matching network/audio style
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  property var connectedDevice: {
    var devs = Bluetooth.devices.values
    for (var i = 0; i < devs.length; i++) {
      if (devs[i].connected) return devs[i]
    }
    return null
  }

  property bool isConnected: connectedDevice !== null
  property string headsetBattery: ""
  
  property string deviceName: {
    if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "Bluetooth Off"
    if (!connectedDevice) return "Disconnected"
    let name = connectedDevice.name || "Unknown Device"
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
    interval: hover.hovered ? 500 : 5000
    running: true
    repeat: true
    onTriggered: battProc.running = true
  }

  content: Item {
    width: parent.width
    height: 30
    
    Text {
      id: icon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: Theme.sizeIcon
      font.bold: true
      color: root.isConnected ? (hover.hovered ? Theme.c(15) : Theme.textPrimary) : Theme.c(1)
      text: (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) ? "bluetooth_disabled" : (root.isConnected ? "bluetooth_connected" : "bluetooth")
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
