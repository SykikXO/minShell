import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"
import "../window"
import "../components"

SidebarWidget {
  id: root
  
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  content: Item {
    width: parent.width
    height: 30
    
    WifiBackend { id: wifi }
    
    Column {
      anchors.centerIn: parent
      spacing: 2
      
      Text {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Theme.iconFont
        font.pixelSize: Theme.sizeIcon
        color: wifi.connectedSsid !== "" ? (hover.hovered ? Theme.c(15) : Theme.textPrimary) : Theme.c(1)
        text: {
          if (!wifi.powered) return "wifi_off"
          if (wifi.scanning) return "wifi_find"
          if (!wifi.connected) return "wifi_off"
          if (wifi.signalStrength > 80) return "signal_wifi_4_bar"
          if (wifi.signalStrength > 60) return "signal_wifi_3_bar"
          if (wifi.signalStrength > 40) return "signal_wifi_2_bar"
          if (wifi.signalStrength > 20) return "signal_wifi_1_bar"
          return "signal_wifi_0_bar"
        }
      }
    }
    
    HoverHandler { id: hover }
    
    SidebarTooltip {
      visible: hover.hovered
      text: {
        if (!wifi.powered) return "Wi-Fi Off"
        if (wifi.scanning) return "Scanning..."
        if (!wifi.connected) return "Disconnected"
        return wifi.connectedSsid + " (" + wifi.signalStrength + "%)"
      }
      targetItem: icon
    }
    
   TapHandler {
      onTapped: proc.running = true
    }
    
    Process {
      id: proc
      command: ["qs", "ipc", "call", "shell", "wifi"]
    }
  }
}
