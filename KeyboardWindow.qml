import Quickshell
import Quickshell.Wayland
import QtQuick

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

  // Force focus when visible
  onVisibleChanged: {
    if (visible) {
      contentScope.forceActiveFocus()
    }
  }
}
