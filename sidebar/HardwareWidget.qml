import QtQuick
import Quickshell
import Quickshell.Io
import "../"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  borderColor: Qt.rgba(Theme.c(7).r, Theme.c(7).g, Theme.c(7).b, 1)
  borderStyle: 3 // dotted
  
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

  content: Column {
    width: parent.width
    spacing: 8
    
    // CPU
    Rectangle {
      id: cpuRect
      width: parent.width - 4; height: 30
      anchors.horizontalCenter: parent.horizontalCenter
      radius: 4
      color: cpuHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 18
        color: cpuHover.hovered ? "black" : getCpuColor(root.cpuVal)
        text: "developer_board"
      }
      
      PopupWindow {
        visible: cpuHover.hovered
        color: "transparent"
        implicitWidth: cpuContentRect.implicitWidth
        implicitHeight: cpuContentRect.implicitHeight
        anchor {
          item: cpuRect
          edges: Edges.Right
          gravity: Edges.Right
          margins.left: Theme.tooltipOffset
        }
        Rectangle {
          id: cpuContentRect
          color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
          border.color: Theme.c(6)
          border.width: 1
          radius: 4
          implicitWidth: cpuTextItem.implicitWidth + 20
          implicitHeight: cpuTextItem.implicitHeight + 20
          Text {
            id: cpuTextItem
            anchors.centerIn: parent
            text: "CPU: " + Math.round(root.cpuVal) + "%"
            font.family: Theme.barFont
            font.pixelSize: 16
            color: Theme.textPrimary
          }
        }
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
      width: parent.width - 4; height: 30
      anchors.horizontalCenter: parent.horizontalCenter
      radius: 4
      color: memHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 18
        color: memHover.hovered ? "black" : getMemColor(root.memVal)
        text: "memory"
      }
      
      PopupWindow {
        visible: memHover.hovered
        color: "transparent"
        implicitWidth: memContentRect.implicitWidth
        implicitHeight: memContentRect.implicitHeight
        anchor {
          item: memRect
          edges: Edges.Right
          gravity: Edges.Right
          margins.left: Theme.tooltipOffset
        }
        Rectangle {
          id: memContentRect
          color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
          border.color: Theme.c(6)
          border.width: 1
          radius: 4
          implicitWidth: memTextItem.implicitWidth + 20
          implicitHeight: memTextItem.implicitHeight + 20
          Text {
            id: memTextItem
            anchors.centerIn: parent
            text: "RAM: " + Math.round(root.memVal) + "%"
            font.family: Theme.barFont
            font.pixelSize: 16
            color: Theme.textPrimary
          }
        }
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
      width: parent.width - 4; height: 30
      anchors.horizontalCenter: parent.horizontalCenter
      radius: 4
      color: tempHover.hovered ? "white" : "transparent"
      Behavior on color { ColorAnimation { duration: 200 } }
      Text {
        anchors.centerIn: parent
        font.family: Theme.iconFont; font.pixelSize: 18
        color: tempHover.hovered ? "black" : getTempColor(root.tempVal)
        text: "thermostat"
      }
      
      PopupWindow {
        visible: tempHover.hovered
        color: "transparent"
        implicitWidth: tempContentRect.implicitWidth
        implicitHeight: tempContentRect.implicitHeight
        anchor {
          item: tempRect
          edges: Edges.Right
          gravity: Edges.Right
          margins.left: Theme.tooltipOffset
        }
        Rectangle {
          id: tempContentRect
          color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
          border.color: Theme.c(6)
          border.width: 1
          radius: 4
          implicitWidth: tempTextItem.implicitWidth + 20
          implicitHeight: tempTextItem.implicitHeight + 20
          Text {
            id: tempTextItem
            anchors.centerIn: parent
            text: "Temp: " + Math.round(root.tempVal) + "°C"
            font.family: Theme.barFont
            font.pixelSize: 16
            color: Theme.textPrimary
          }
        }
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
