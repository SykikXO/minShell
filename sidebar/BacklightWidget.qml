import QtQuick
import Quickshell
import Quickshell.Io
import "../"
import "../components"

SidebarWidget {
  id: root
  
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  property bool isHyprsunsetRunning: false
  property real brightnessVal: 0
  
  content: Item {
    width: 30
    height: 30
    
    Text {
      id: brightnessIcon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: Theme.sizeIcon
      color: mouseArea.containsMouse ? Theme.c(15) : Theme.textPrimary
      text: root.brightnessVal > 70 ? "brightness_high" : (root.brightnessVal > 30 ? "brightness_medium" : "brightness_low")
    }
    
    MouseArea {
      id: mouseArea
      width: parent.width; height: parent.height
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

    SidebarTooltip {
      visible: mouseArea.containsMouse
      text: "Brightness: " + root.brightnessVal + "%"
      targetItem: mouseArea
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
