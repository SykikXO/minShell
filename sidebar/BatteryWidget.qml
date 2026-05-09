import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../"

SidebarWidget {
  id: root
  // Waybar battery: border-bottom: 1px solid alpha(@color6, 1); background-color: alpha(@color9, 1);
  // Charging: @green. Critical: @color3 with blink
  
  property var bat: UPower.displayDevice
  property bool isCharging: bat && bat.state === 1 // 1 is charging, 2 is discharging
  property bool isCritical: bat && (bat.percentage * 100) <= 15
  property bool showTime: false
  
  bgColor: {
    if (isCharging) return Theme.green;
    if (isCritical) return Theme.c(3);
    return Qt.darker(Theme.c(9), 2.0);
  }
  
  borderColor: isCharging ? Theme.green : Qt.rgba(Theme.c(6).r, Theme.c(6).g, Theme.c(6).b, 1)
  borderStyle: 1 // solid
  
  // Critical blink animation
  SequentialAnimation on opacity {
    running: root.isCritical && !root.isCharging
    loops: Animation.Infinite
    NumberAnimation { to: 0.5; duration: 300 }
    NumberAnimation { to: 1.0; duration: 300 }
  }
  
  content: Item {
    width: parent.width
    height: 44
    
    Column {
      visible: !root.showTime
      anchors.centerIn: parent
      spacing: 2
      Text {
        id: batIcon
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Theme.iconFont
        font.pixelSize: 24
        color: Theme.white
        text: {
          let p = root.bat ? (root.bat.percentage * 100) : 100;
          if (root.isCharging) {
            return "battery_charging_full";
          }
          if (p > 90) return "battery_full";
          if (p > 80) return "battery_6_bar";
          if (p > 60) return "battery_5_bar";
          if (p > 40) return "battery_4_bar";
          if (p > 30) return "battery_3_bar";
          if (p > 20) return "battery_2_bar";
          if (p > 10) return "battery_1_bar";
          return "battery_0_bar";
        }
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Theme.barFont
        font.pixelSize: 15
        font.bold: true
        color: Theme.white
        text: root.bat ? Math.round(root.bat.percentage * 100)+"%" : "100%"
      }
    }

    Text {
      visible: root.showTime
      anchors.centerIn: parent
      font.family: Theme.barFont
      font.pixelSize: 15
      color: Theme.white
      horizontalAlignment: Text.AlignHCenter
      lineHeight: 0.9
      text: {
        let sec = root.isCharging ? (root.bat ? root.bat.timeToFull : 0) : (root.bat ? root.bat.timeToEmpty : 0);
        if (!sec) return "---";
        let h = Math.floor(sec / 3600);
        let m = Math.floor((sec % 3600) / 60);
        if (h > 0) return h + "h\n" + m + "m";
        return m + "m";
      }
    }
    
    TapHandler {
      onTapped: root.showTime = !root.showTime
    }
  }
}
