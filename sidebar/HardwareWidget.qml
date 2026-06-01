import QtQuick
import Quickshell
import Quickshell.Io
import "../"
import "../components"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  property real cpuVal: 0
  property real memVal: 0
  property real tempVal: 0

  function getCpuColor(val) {
    if (val >= 80) return Theme.c(1);
    if (val >= 50) return Theme.c(3);
    return Theme.textPrimary;
  }
  function getMemColor(val) {
    if (val >= 85) return Theme.c(1);
    if (val >= 60) return Theme.c(3);
    return Theme.textPrimary;
  }
  function getTempColor(val) {
    if (val >= 75) return Theme.c(1);
    if (val >= 55) return Theme.c(3);
    return Theme.textPrimary;
  }

  content: Row {
    spacing: 2

    // CPU
    Rectangle {
      id: cpuRect
      width: 32; height: 32
      radius: 4
      color: cpuHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 20
        color: cpuHover.hovered ? "black" : getCpuColor(root.cpuVal)
        text: "developer_board"
      }
      
      SidebarTooltip {
        visible: cpuHover.hovered
        text: "CPU: " + Math.round(root.cpuVal) + "%"
        targetItem: cpuRect
      }
      HoverHandler { id: cpuHover }
      
      Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'"]
        running: true
        stdout: StdioCollector {
          onStreamFinished: {
            let val = parseFloat(this.text);
            if (!isNaN(val)) root.cpuVal = val;
          }
        }
      }
      Timer { interval: cpuHover.hovered ? 500 : 5000; running: true; repeat: true; onTriggered: cpuProc.running = true }
    }
    
    // Memory
    Rectangle {
      id: memRect
      width: 32; height: 32
      radius: 4
      color: memHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 20
        color: memHover.hovered ? "black" : getMemColor(root.memVal)
        text: "memory"
      }
      
      SidebarTooltip {
        visible: memHover.hovered
        text: "RAM: " + Math.round(root.memVal) + "%"
        targetItem: memRect
      }
      HoverHandler { id: memHover }
      
      Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        running: true
        stdout: StdioCollector {
          onStreamFinished: {
            let val = parseFloat(this.text);
            if (!isNaN(val)) root.memVal = val;
          }
        }
      }
      Timer { interval: memHover.hovered ? 500 : 5000; running: true; repeat: true; onTriggered: memProc.running = true }
    }
    
    // Temperature
    Rectangle {
      id: tempRect
      width: 32; height: 32
      radius: 4
      color: tempHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 20
        color: tempHover.hovered ? "black" : getTempColor(root.tempVal)
        text: "thermostat"
      }
      
      SidebarTooltip {
        visible: tempHover.hovered
        text: "Temp: " + Math.round(root.tempVal) + "°C"
        targetItem: tempRect
      }
      HoverHandler { id: tempHover }
      
      Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/hwmon/hwmon6/temp1_input 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
          onStreamFinished: {
            let val = parseInt(this.text) / 1000;
            if (!isNaN(val) && val > 0) root.tempVal = val;
          }
        }
      }
      Timer { interval: tempHover.hovered ? 500 : 5000; running: true; repeat: true; onTriggered: tempProc.running = true }
    }
  }
}
