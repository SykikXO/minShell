import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"
import "../window"

SidebarWidget {
  id: root
  // Waybar network: background: alpha(@color2, 0.7); border-bottom: 1px dashed alpha(@color7, 1);
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  borderColor: Qt.rgba(Theme.c(7).r, Theme.c(7).g, Theme.c(7).b, 1)
  borderStyle: 2 // dashed
  
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
        font.pixelSize: 18
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
    
    PopupWindow {
      id: networkToolTip
      visible: hover.hovered
      color: "transparent"
      implicitWidth: contentRect.implicitWidth
      implicitHeight: contentRect.implicitHeight
      anchor {
        item: root
        edges: Edges.Right
        gravity: Edges.Right
        margins.left: Theme.tooltipOffset
      }

      Rectangle {
        id: contentRect
        color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
        border.color: Theme.c(6)
        border.width: 1
        radius: 4
        implicitWidth: textItem.implicitWidth + 20
        implicitHeight: textItem.implicitHeight + 20

        Text {
          id: textItem
          anchors.centerIn: parent
          text: {
            if (!wifi.powered) return "Wi-Fi Off"
            if (wifi.scanning) return "Scanning..."
            if (!wifi.connected) return "Disconnected"
            return wifi.connectedSsid + " (" + wifi.signalStrength + "%)"
          }
          font.family: Theme.barFont
          font.pixelSize: 16
          color: Theme.textPrimary
        }
      }
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
