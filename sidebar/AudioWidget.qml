import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../"

SidebarWidget {
  id: root
  // Waybar pulseaudio: border-bottom: 1px dashed alpha(@color10, 1); background: alpha(@color2, 0.7)
  bgColor: Qt.rgba(Theme.c(2).r, Theme.c(2).g, Theme.c(2).b, 0.7)
  borderColor: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio.muted ? Theme.c(1) : Qt.rgba(Theme.c(10).r, Theme.c(10).g, Theme.c(10).b, 1)
  borderStyle: 2 // dashed
  
  property var sink: Pipewire.defaultAudioSink
  
  content: Item {
    width: parent.width
    height: 30
    
    PwObjectTracker {
      objects: [root.sink]
    }

    Text {
      id: audioIcon
      anchors.centerIn: parent
      font.family: Theme.iconFont
      font.pixelSize: 18
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

    PopupWindow {
      id: audioToolTip
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
          text: {
            if (root.sink && root.sink.audio && root.sink.audio.muted) return "Muted";
            let v = root.sink && root.sink.audio && !isNaN(root.sink.audio.volume) ? root.sink.audio.volume : 0;
            return "Volume: " + Math.round(v * 100) + "%";
          }
          font.family: Theme.barFont
          font.pixelSize: 16
          color: Theme.textPrimary
        }
      }
    }
    
    Process {
      id: proc
      command: ["pwvucontrol"]
    }
  }
}
