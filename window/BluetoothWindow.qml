import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../"

KeyboardWindow {
  id: btWindow
  visible: true
  popupWidth: 480
  popupHeight: 560

  // ── State ──
  property var adapter: Bluetooth.defaultAdapter
  property bool hideOnConnect: false
  property bool showKeybinds: false
  property string recentAddress: ""
  property int _refreshTick: 0

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: btWindow._refreshTick++
  }

  // ── Derived state ──
  property var sortedDevices: {
    var _ = btWindow._refreshTick
    var devs = Bluetooth.devices.values.slice()
    devs.sort((a, b) => {
      var scoreA = 0
      if (a.connected) scoreA += 1000
      if (a.trusted) scoreA += 100
      if (a.paired) scoreA += 10

      var scoreB = 0
      if (b.connected) scoreB += 1000
      if (b.trusted) scoreB += 100
      if (b.paired) scoreB += 10

      if (scoreA !== scoreB) return scoreB - scoreA
      return (a.name || a.address || "").localeCompare(b.name || b.address || "")
    })
    return devs
  }

  property var connectedDevice: {
    var devs = Bluetooth.devices.values
    for (var i = 0; i < devs.length; i++) {
      if (devs[i].connected) return devs[i]
    }
    return null
  }

  property color headerColor: {
    if (!adapter || !adapter.enabled) return Theme.red
    if (connectedDevice) return Theme.green
    return Theme.accent
  }

  // ── Icon helpers ──
  function deviceIcon(dev) {
    if (!dev) return "bluetooth_disabled"
    var n = (dev.name || "").toLowerCase()
    if (n.indexOf("headphone") >= 0 || n.indexOf("airpod") >= 0 || n.indexOf("buds") >= 0 || n.indexOf("earphone") >= 0)
      return "headphones"
    if (n.indexOf("keyboard") >= 0 || n.indexOf("keychron") >= 0)
      return "keyboard"
    if (n.indexOf("mouse") >= 0 || n.indexOf("trackpad") >= 0)
      return "mouse"
    if (n.indexOf("phone") >= 0 || n.indexOf("pixel") >= 0 || n.indexOf("iphone") >= 0 || n.indexOf("galaxy") >= 0 || n.indexOf("oneplus") >= 0 || n.indexOf("redmi") >= 0 || n.indexOf("poco") >= 0)
      return "smartphone"
    if (n.indexOf("speaker") >= 0 || n.indexOf("soundbar") >= 0)
      return "speaker"
    if (n.indexOf("watch") >= 0 || n.indexOf("band") >= 0)
      return "watch"
    if (n.indexOf("tv") >= 0 || n.indexOf("monitor") >= 0 || n.indexOf("display") >= 0)
      return "tv"
    if (n.indexOf("controller") >= 0 || n.indexOf("gamepad") >= 0 || n.indexOf("joystick") >= 0)
      return "videogame_asset"
    if (n.indexOf("laptop") >= 0)
      return "laptop_mac"
    return "bluetooth"
  }

  function batteryIcon(level) {
    if (level >= 90)  return "battery_full"
    if (level >= 80)  return "battery_6_bar"
    if (level >= 70)  return "battery_5_bar"
    if (level >= 60)  return "battery_4_bar"
    if (level >= 50)  return "battery_3_bar"
    if (level >= 40)  return "battery_2_bar"
    if (level >= 30)  return "battery_1_bar"
    if (level >= 20)  return "battery_0_bar"
    if (level >= 10)  return "battery_0_bar"
    return "battery_0_bar"
  }

  function statusIcon(dev) {
    if (dev.connected) return "check_circle"
    if (dev.paired)    return "check"
    if (dev.trusted)   return "verified"
    return ""
  }

  // ── Persistent history ──
  Process {
    id: readHistory
    command: ["bash", "-c", "cat $HOME/.cache/quickshell/bt_recent 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: btWindow.recentAddress = this.text.trim()
    }
  }

  Process {
    id: writeHistory
    running: false
  }

  function saveRecent(address) {
    writeHistory.command = ["bash", "-c",
      "mkdir -p $HOME/.cache/quickshell && echo '" + address + "' > $HOME/.cache/quickshell/bt_recent"]
    writeHistory.running = true
    recentAddress = address
  }

  function reconnectRecent() {
    if (!recentAddress) return
    var devs = sortedDevices
    for (var i = 0; i < devs.length; i++) {
      if (devs[i].address === recentAddress) {
        devs[i].connect()
        return
      }
    }
  }

  // ── Keyboard handler ──
  Item {
    anchors.fill: parent
    focus: true

    Keys.onPressed: (event) => {
      var count = btWindow.sortedDevices.length
      var dev = btWindow.sortedDevices[deviceList.currentIndex]
      switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_Down:
          if (deviceList.currentIndex < count - 1)
            deviceList.currentIndex++
          event.accepted = true
          break
        case Qt.Key_K:
        case Qt.Key_Up:
          if (deviceList.currentIndex > 0)
            deviceList.currentIndex--
          event.accepted = true
          break
        case Qt.Key_G:
          if (event.modifiers & Qt.ShiftModifier)
            deviceList.currentIndex = count - 1
          else
            deviceList.currentIndex = 0
          event.accepted = true
          break
        case Qt.Key_C:
        case Qt.Key_Return:
        case Qt.Key_Enter:
          if (dev) {
            if (dev.connected) {
              dev.disconnect()
            } else {
              if (!dev.paired) dev.pair()
              dev.connect()
              dev.trusted = true
              saveRecent(dev.address)
              if (hideOnConnect) btWindow.visible = false
            }
          }
          event.accepted = true
          break
        case Qt.Key_T:
          if (dev) dev.trusted = !dev.trusted
          event.accepted = true
          break
        case Qt.Key_P:
          if (dev) {
            if (dev.paired) {
              dev.forget()
              deviceList.currentIndex = Math.max(0, deviceList.currentIndex - 1)
            } else {
              dev.pair()
            }
          }
          event.accepted = true
          break
        case Qt.Key_O:
          if (adapter) adapter.enabled = !adapter.enabled
          event.accepted = true
          break
        case Qt.Key_S:
          if (!adapter.discovering) adapter.discovering = true
          event.accepted = true
          break
        case Qt.Key_X:
          if (dev) {
            if (dev.connected) dev.disconnect()
            dev.forget()
          }
          deviceList.currentIndex = Math.max(0, deviceList.currentIndex - 1)
          event.accepted = true
          break
        case Qt.Key_R:
          reconnectRecent()
          event.accepted = true
          break
        case Qt.Key_H:
          hideOnConnect = !hideOnConnect
          event.accepted = true
          break
        case Qt.Key_Slash:
          showKeybinds = !showKeybinds
          event.accepted = true
          break
        case Qt.Key_Q:
        case Qt.Key_Escape:
          btWindow.visible = false
          event.accepted = true
          break
      }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 8

      // ══════════════════════════════
      // ── Header: icon + title + dot ──
      // ══════════════════════════════
      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 10

        // Bluetooth icon
        Text {
          id: headerIcon
          text: "bluetooth"
          font.pixelSize: Theme.sizeHeaderTitle
          font.family: Theme.iconFont
          color: btWindow.headerColor
          Behavior on color { ColorAnimation { duration: 300 } }

          SequentialAnimation on opacity {
            id: blinkAnim
            running: btWindow.adapter ? btWindow.adapter.discovering : false
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
          }

          Connections {
            target: btWindow.adapter
            function onDiscoveringChanged() {
              if (!btWindow.adapter.discovering) headerIcon.opacity = 1.0
            }
          }
        }

        // Title
        Text {
          text: "Bluetooth"
          font.pixelSize: Theme.sizeHeaderTitle
          font.family: Theme.monoFont
          font.bold: true
          color: btWindow.headerColor
          Behavior on color { ColorAnimation { duration: 300 } }
        }

        // Power indicator dot
        Rectangle {
          width: 10
          height: 10
          radius: 5
          Layout.alignment: Qt.AlignVCenter
          color: {
            if (!btWindow.adapter || !btWindow.adapter.enabled) return Theme.red
            if (btWindow.connectedDevice) return Theme.green
            return Theme.accent
          }
          Behavior on color { ColorAnimation { duration: 300 } }

          SequentialAnimation on scale {
            running: btWindow.adapter ? btWindow.adapter.discovering : false
            loops: Animation.Infinite
            NumberAnimation { to: 1.4; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
          }
        }
      }

      // ── Connected device info ──
      Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 8

        Text {
          font.pixelSize: Theme.sizeStatusText
          font.family: Theme.monoFont
          color: btWindow.connectedDevice ? Theme.textSecondary : Theme.textMuted
          text: {
            var dev = btWindow.connectedDevice
            if (!dev) return "no device connected"
            return dev.name || "Unknown"
          }
        }

        Text {
          visible: btWindow.connectedDevice && btWindow.connectedDevice.batteryAvailable
          font.pixelSize: Theme.sizeStatusText
          font.family: Theme.monoFont
          color: Theme.textSecondary
          textFormat: Text.RichText
          text: {
            var dev = btWindow.connectedDevice
            if (dev && dev.batteryAvailable) {
              var pct = Math.round(dev.battery * 100)
              return "<span style=\"font-family: '" + Theme.iconFont + "';\">" + btWindow.batteryIcon(pct) + "</span>&nbsp;" + pct + "%"
            }
            return ""
          }
        }
      }

      // ══════════════════════════════
      // ── Keybind bar ──
      // ══════════════════════════════
      Flow {
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: parent.width
        spacing: 12
        
        Repeater {
          model: [
            {k: "c", d: "conn"},
            {k: "t", d: "trust"},
            {k: "p", d: "pair"},
            {k: "x", d: "remove"},
            {k: "o", d: "power"},
            {k: "s", d: "scan"},
            {k: "/", d: "keys"},
          ]
          delegate: Row {
            spacing: 6
            Rectangle {
              color: Theme.bgSecondary
              border.color: Theme.accent
              border.width: 1
              radius: 4
              antialiasing: true
              width: kText.contentWidth + 10
              height: kText.contentHeight + 6
              Text {
                id: kText
                text: modelData.k
                font.family: Theme.monoFont
                color: Theme.accent
                font.bold: true
                anchors.centerIn: parent
              }
            }
            Text {
              text: modelData.d
              font.family: Theme.monoFont
              color: Theme.textDark
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }

      // ── Separator ──
      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Theme.borderColor
      }

      // ══════════════════════════════
      // ── Device list / keybinds ──
      // ══════════════════════════════
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
          id: deviceList
          visible: !btWindow.showKeybinds
          anchors.fill: parent
          clip: true
          spacing: 2
          model: btWindow.sortedDevices
          currentIndex: 0
          highlightFollowsCurrentItem: true
          keyNavigationEnabled: false

          delegate: Item {
            required property var modelData
            required property int index
            width: deviceList.width
            height: 34

            property bool isCurrent: index === deviceList.currentIndex

            Rectangle {
              anchors.fill: parent
              radius: 6
              color: isCurrent ? Theme.bgHover : "transparent"
              opacity: isCurrent ? 0.8 : 0
              Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8

              Text {
                text: isCurrent ? "▸" : " "
                font.pixelSize: Theme.sizeListText
                font.family: Theme.monoFont
                color: Theme.accent
                Layout.preferredWidth: 12
              }

              Text {
                text: btWindow.deviceIcon(modelData)
                font.pixelSize: Theme.sizeDeviceIcon
                font.family: Theme.iconFont
                color: {
                  if (modelData.connected) return Theme.green
                  if (isCurrent) return Theme.accent
                  return Theme.textMuted
                }
                Layout.preferredWidth: 20
                Behavior on color { ColorAnimation { duration: 120 } }
              }

              Text {
                text: modelData.name || modelData.address || "Unknown"
                font.pixelSize: Theme.sizeListText
                font.family: Theme.monoFont
                color: {
                  if (modelData.connected) return Theme.devConnected
                  if (modelData.paired)    return Theme.devPaired
                  if (modelData.trusted)   return Theme.devTrusted
                  return "#88c0d0"
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 120 } }
              }

              Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                  visible: modelData.connected
                  color: "#a3be8c"
                  radius: 8
                  width: 16; height: 16
                  antialiasing: true
                  Text { text: "C"; font.pixelSize: 10; font.bold: true; color: Theme.bgPrimary; anchors.centerIn: parent }
                }
                Item {
                  visible: modelData.trusted
                  width: 16; height: 16
                  Rectangle {
                    anchors.fill: parent
                    color: "#81a1c1"
                    opacity: 0.2
                    radius: 8
                    antialiasing: true
                  }
                  Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#81a1c1"
                    border.width: 1
                    radius: 8
                    antialiasing: true
                  }
                  Text { text: "T"; font.pixelSize: 10; font.bold: true; color: "#81a1c1"; anchors.centerIn: parent }
                }
                Rectangle {
                  visible: modelData.paired
                  color: "transparent"
                  border.color: "#ebcb8b"
                  border.width: 1
                  radius: 8
                  width: 16; height: 16
                  antialiasing: true
                  Text { text: "P"; font.pixelSize: 10; font.bold: true; color: "#ebcb8b"; anchors.centerIn: parent }
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            visible: deviceList.count === 0
            spacing: 12

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (!btWindow.adapter || !btWindow.adapter.enabled) ? "bluetooth_disabled" : "bluetooth"
              font.pixelSize: Theme.sizeEmptyIcon
              font.family: Theme.iconFont
              color: Theme.textDark
              horizontalAlignment: Text.AlignHCenter
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: {
                if (!btWindow.adapter || !btWindow.adapter.enabled)
                  return "bluetooth off  ·  [o] to enable"
                return "no devices  ·  [s] to scan"
              }
              horizontalAlignment: Text.AlignHCenter
              font.pixelSize: Theme.sizeEmptyState
              font.family: Theme.monoFont
              color: Theme.textMuted
            }
          }
        }

        // ── Keybinds overlay ──
        Rectangle {
          visible: btWindow.showKeybinds
          anchors.fill: parent
          color: Theme.bgPrimary
          radius: 6

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
              model: [
                {k: "j/k", d: "navigate"},
                {k: "g", d: "first / last"},
                {k: "c/enter", d: "connect / disconnect"},
                {k: "t", d: "toggle trust"},
                {k: "p", d: "toggle pair"},
                {k: "x", d: "remove device"},
                {k: "o", d: "toggle power"},
                {k: "s", d: "start scan"},
                {k: "r", d: "reconnect recent"},
                {k: "h", d: "hide on connect"},
                {k: "q/esc", d: "close"},
                {k: "/", d: "hide this view"},
              ]

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

      // ── Footer ──
      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          text: "bluetooth"
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.iconFont
          color: Theme.textDark
        }

        Text {
          Layout.fillWidth: true
          text: btWindow.adapter ? btWindow.adapter.name : "no adapter"
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.monoFont
          color: Theme.textDark
        }

        Text {
          text: btWindow.sortedDevices.length + " devices"
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.monoFont
          color: Theme.textDark
        }
      }
    }
  }
}
