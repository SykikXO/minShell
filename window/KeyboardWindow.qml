import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../"
PanelWindow {
  id: kbWindow

  // ── Layer shell: fullscreen transparent overlay with centered popup ──
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  focusable: true
  exclusionMode: ExclusionMode.Ignore
  aboveWindows: true

  // OnDemand = gets keyboard focus without locking out compositor keybinds
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  WlrLayershell.layer: WlrLayer.Overlay

  // ── Popup dimensions (override in child) ──
  property int popupWidth: 380
  property int popupHeight: 520

  // ── Keybind overlay (shared by all keyboard-driven windows) ──
  property bool showKeybinds: false
  property var overlayKeybinds: []

  // Colors are now in Theme.qml

  // ── Content slot: children go into the FocusScope inside the popup ──
  default property alias content: contentScope.data

  // Click outside the popup → close
  MouseArea {
    anchors.fill: parent
    onClicked: kbWindow.visible = false
  }

  // ── Centered popup rectangle ──
  Rectangle {
    id: popupRect
    width: kbWindow.popupWidth
    height: kbWindow.popupHeight
    anchors.centerIn: parent
    color: Theme.bgPrimary
    radius: 12
    border.width: 1
    border.color: Theme.borderColor

    // Prevent clicks on the popup from closing it
    MouseArea {
      anchors.fill: parent
      // Accept the click so it doesn't fall through to the backdrop
      propagateComposedEvents: false
    }

    // Content goes here — FocusScope ensures focus delegation works
    FocusScope {
      id: contentScope
      anchors.fill: parent
      focus: true
    }
  }

  // Force focus when visible; reset overlay on close
  onVisibleChanged: {
    if (visible) {
      contentScope.forceActiveFocus()
    } else {
      showKeybinds = false
    }
  }

  // ── Keybind overlay ──
  Rectangle {
    visible: kbWindow.showKeybinds
    anchors.fill: parent
    color: Theme.bgPrimary
    radius: 12
    z: 10

    ColumnLayout {
      anchors.centerIn: parent
      spacing: 6

      Text {
        text: "Keybinds"
        font.pixelSize: Theme.sizeListText
        font.family: Theme.monoFont
        font.bold: true
        color: Theme.accent
        Layout.alignment: Qt.AlignHCenter
        bottomPadding: 8
      }

      Repeater {
        model: kbWindow.overlayKeybinds

        delegate: Row {
          spacing: 16
          Layout.alignment: Qt.AlignHCenter

          Text {
            text: modelData.k
            font.family: Theme.monoFont
            font.bold: true
            color: Theme.accent
            horizontalAlignment: Text.AlignRight
            width: 80
          }

          Text {
            text: modelData.d
            font.family: Theme.monoFont
            color: Theme.textSecondary
          }
        }
      }

      Text {
        text: "[ / ] to hide"
        font.pixelSize: Theme.sizeFooter
        font.family: Theme.monoFont
        color: Theme.textMuted
        Layout.alignment: Qt.AlignHCenter
        topPadding: 8
      }
    }
  }
}
