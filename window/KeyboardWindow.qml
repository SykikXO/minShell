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

    // ── Keybind overlay (inside popup) ──
    Rectangle {
      id: overlayRect
      visible: kbWindow.showKeybinds
      anchors.fill: parent
      color: Theme.bgPrimary
      radius: 12
      z: 10

      Column {
        id: overlayCol
        anchors {
          horizontalCenter: parent.horizontalCenter
          verticalCenter: parent.verticalCenter
        }
        spacing: 4
        width: parent.width - 40

        Text {
          text: "Keybinds"
          font.pixelSize: Theme.sizeHeaderTitle
          font.family: Theme.monoFont
          font.bold: true
          color: "#ffffff"
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          bottomPadding: 12
        }

        Repeater {
          model: kbWindow.overlayKeybinds

          delegate: Row {
            x: overlayCol.width / 2 - keyText.width - (overlayRect.width - overlayCol.width)
            spacing: 20

            Text {
              id: keyText
              text: modelData.k
              font.family: Theme.monoFont
              font.bold: true
              color: "#ffffff"
              horizontalAlignment: Text.AlignRight
              width: 90
              font.pixelSize: Theme.sizeListText
            }

            Text {
              text: modelData.d
              font.family: Theme.monoFont
              color: "#ffffff"
              font.pixelSize: Theme.sizeListText
            }
          }
        }

        Text {
          text: "[ / ] to hide"
          font.pixelSize: Theme.sizeStatusText
          font.family: Theme.monoFont
          color: "#888888"
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          topPadding: 16
        }
      }
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
}
