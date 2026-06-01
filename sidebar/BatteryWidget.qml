import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../"

SidebarWidget {
  id: root
  

  property var bat: UPower.displayDevice
  property int percentage: bat ? Math.round(bat.percentage * 100) : 100
  property bool isCharging: bat && bat.state === 1
  property bool isCritical: percentage <= 15
  property bool isLow: percentage > 15 && percentage <= 25
  property bool isHighCharging: isCharging && percentage > 80
  property bool showTime: false

  
  

  property bool blinkState: false

  bgColor: {
    if (isCritical && !isCharging) {
      return blinkState ? "black" : Theme.c(3);
    }
    if (isCharging && percentage > 80) return Theme.c(3);
    if (isLow && !isCharging) return Theme.orange;
    if (isCharging) return Theme.green;
    return Qt.darker(Theme.c(9), 2.0);
  }

  Timer {
    interval: 300
    running: isCritical && !isCharging
    repeat: true
    onTriggered: root.blinkState = !root.blinkState
  }

  SequentialAnimation on opacity {
    running: isLow && !isCharging
    loops: Animation.Infinite
    NumberAnimation { to: 0.5; duration: 800 }
    NumberAnimation { to: 1.0; duration: 800 }
  }
  
  content: Item {
    width: childrenRect.width
    height: childrenRect.height

    Row {
      visible: !root.showTime
      anchors.centerIn: parent
      spacing: 4
      Text {
        id: batIcon
        font.family: Theme.iconFont
        font.pixelSize: 20
        color: {
          if (isCritical && !isCharging) return blinkState ? Theme.c(3) : "black";
          if (isCharging && percentage > 80) return "black";
          if (isLow && !isCharging) return "black";
          return Theme.white;
        }
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
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.barFont
        font.pixelSize: 15
        font.bold: true
        color: {
          if (isCritical && !isCharging) return blinkState ? Theme.c(3) : "black";
          if (isCharging && percentage > 80) return "black";
          if (isLow && !isCharging) return "black";
          return Theme.white;
        }
        text: root.bat ? Math.round(root.bat.percentage * 100)+"%" : "100%"
      }
    }

    Text {
      visible: root.showTime
      anchors.centerIn: parent
      font.family: Theme.barFont
      font.pixelSize: 15
      color: {
        if (isCritical && !isCharging) return blinkState ? Theme.c(3) : "black";
        if (isCharging && percentage > 80) return "black";
        if (isLow && !isCharging) return "black";
        return Theme.white;
      }
      horizontalAlignment: Text.AlignHCenter
      text: {
        let sec = root.isCharging ? (root.bat ? root.bat.timeToFull : 0) : (root.bat ? root.bat.timeToEmpty : 0);
        if (!sec) return "---";
        let h = Math.floor(sec / 3600);
        let m = Math.floor((sec % 3600) / 60);
        if (h > 0) return h + "h " + m + "m";
        return m + "m";
      }
    }
    
    TapHandler {
      onTapped: root.showTime = !root.showTime
    }
  }
}
