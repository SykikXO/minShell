import QtQuick
import Quickshell
import Quickshell.Io
import "../"

SidebarWidget {
  id: root
  // Waybar backlight: border-bottom: 1px dashed alpha(@color10, 1); background: alpha(@color2, 0.7)
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  borderColor: Qt.rgba(Theme.c(10).r, Theme.c(10).g, Theme.c(10).b, 1)
  borderStyle: 2 // dashed
  
  property bool isHyprsunsetRunning: false
  property real brightnessVal: 0
  
  function getBrightnessColor(val) {
    if (root.isHyprsunsetRunning) return Theme.c(9);
    if (val >= 75) return Theme.c(1);
    if (val >= 55) return Theme.c(3);
    return Theme.textPrimary;
  }
  
  content: Item {
    width: parent.width
    height: 30
    
    Text {
      id: brightnessIcon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: 18
      color: mouseArea.containsMouse ? Theme.c(15) : root.getBrightnessColor(root.brightnessVal)
      text: root.brightnessVal > 70 ? "brightness_high" : (root.brightnessVal > 30 ? "brightness_medium" : "brightness_low")
    }
    
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        procClick.running = true;
        root.isHyprsunsetRunning = !root.isHyprsunsetRunning;
      }
      onWheel: (wheel) => {
        if (wheel.angleDelta.y > 0) {
          procUp.running = true;
        } else {
          procDown.running = true;
        }
        updateTimerWheel.start();
      }
    }

    PopupWindow {
      id: brightnessToolTip
      visible: mouseArea.containsMouse
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
          text: "Brightness: " + root.brightnessVal + "%"
          font.family: Theme.barFont
          font.pixelSize: 16
          color: Theme.textPrimary
        }
      }
    }

    Timer {
      id: updateTimerWheel
      interval: 100
      repeat: false
      onTriggered: updateProc.running = true
    }

    Process {
      id: procClick
      command: ["/home/sykik/.config/scripts/hyprsunset_toggle.sh"]
    }
    
    Process { id: procUp; command: ["brillo", "-A", "2"] }
    Process { id: procDown; command: ["brillo", "-U", "2"] }
    
    Process {
      id: updateProc
      command: ["brillo", "-G"]
      running: true
      stdout: StdioCollector {
        onStreamFinished: {
          let val = Math.round(parseFloat(this.text));
          root.brightnessVal = val;
        }
      }
    }

    Process {
      id: sunsetCheckProc
      command: ["sh", "-c", "pidof hyprsunset > /dev/null && echo 1 || echo 0"]
      running: true
      stdout: StdioCollector {
        onStreamFinished: {
          root.isHyprsunsetRunning = (this.text.trim() === "1");
        }
      }
    }

    Timer { interval: mouseArea.containsMouse ? 500 : 5000; running: true; repeat: true; onTriggered: { updateProc.running = true; sunsetCheckProc.running = true; } }
  }
}
