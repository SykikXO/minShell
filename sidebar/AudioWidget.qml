import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../"
import "../components"

SidebarWidget {
  id: root
  
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  
  
  
  property var sink: Pipewire.defaultAudioSink
  
  content: Item {
    width: childrenRect.width
    height: childrenRect.height
    
    PwObjectTracker {
      objects: [root.sink]
    }

    Text {
      id: audioIcon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: Theme.sizeIcon
      font.bold: true
      color: mouseArea.containsMouse ? Theme.c(15) : (root.sink && root.sink.audio && root.sink.audio.muted ? Theme.c(1) : Theme.textPrimary)
      text: {
        if (root.sink && root.sink.audio && root.sink.audio.muted) return "volume_off";
        let v = root.sink && root.sink.audio && !isNaN(root.sink.audio.volume) ? root.sink.audio.volume : 0;
        if (v === 0) return "volume_mute";
        if (v < 0.5) return "volume_down";
        return "volume_up";
      }
    }
    
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      onClicked: proc.running = true
      onWheel: (wheel) => {
        if (!root.sink || !root.sink.audio) return;
        let v = root.sink.audio.volume;
        if (wheel.angleDelta.y > 0) {
          v = Math.min(1.0, v + 0.001);
        } else {
          v = Math.max(0.0, v - 0.001);
        }
        root.sink.audio.volume = v;
      }
    }

    SidebarTooltip {
      visible: mouseArea.containsMouse
      text: {
        if (root.sink && root.sink.audio && root.sink.audio.muted) return "Muted";
        let v = root.sink && root.sink.audio && !isNaN(root.sink.audio.volume) ? root.sink.audio.volume : 0;
        return "Volume: " + Math.round(v * 100) + "%";
      }
      targetItem: mouseArea
    }
    
    Process {
      id: proc
      command: ["pwvucontrol"]
    }
  }
}
