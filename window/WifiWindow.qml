import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../"

KeyboardWindow {
  id: wifiWindow
  visible: true
  popupWidth: 480
  popupHeight: 560

  // ── Backend ──
  WifiBackend { id: wifi }

  // ── State ──
  property bool passwordMode: false
  property string pendingSsid: ""

  // ── Derived state ──
  property color headerColor: {
    if (!wifi.powered) return Theme.red
    if (wifi.connected) return Theme.green
    return Theme.accent
  }

  // ── Icon helpers ──
  function signalIcon(level) {
    if (level >= 80) return "wifi"
    if (level >= 60) return "network_wifi_3_bar"
    if (level >= 40) return "network_wifi_2_bar"
    if (level >= 20) return "network_wifi_1_bar"
    return "signal_wifi_0_bar"
  }

  function securityIcon(sec) {
    if (sec === "Open") return ""
    return "lock"
  }

  // ══════════════════════════════════════════
  // ── Keyboard handler ──
  // ══════════════════════════════════════════
  Item {
    anchors.fill: parent
    focus: !wifiWindow.passwordMode

    Keys.onPressed: (event) => {
      var count = wifi.networks.count
      switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_Down:
          if (networkList.currentIndex < count - 1)
            networkList.currentIndex++
          event.accepted = true
          break
        case Qt.Key_K:
        case Qt.Key_Up:
          if (networkList.currentIndex > 0)
            networkList.currentIndex--
          event.accepted = true
          break
        case Qt.Key_G:
          if (event.modifiers & Qt.ShiftModifier)
            networkList.currentIndex = count - 1
          else
            networkList.currentIndex = 0
          event.accepted = true
          break
        case Qt.Key_Return:
        case Qt.Key_Enter:
          if (count > 0) {
            var net = wifi.networks.get(networkList.currentIndex)
            if (net) {
              if (net.connected) {
                wifi.disconnect()
              } else if (net.known || net.security === "Open") {
                wifi.connect(net.ssid)
              } else {
                // Need password — enter password mode
                wifiWindow.pendingSsid = net.ssid
                wifiWindow.passwordMode = true
              }
            }
          }
          event.accepted = true
          break
        case Qt.Key_P:
          wifi.togglePower()
          event.accepted = true
          break
        case Qt.Key_S:
          wifi.scan()
          event.accepted = true
          break
        case Qt.Key_D:
          wifi.disconnect()
          event.accepted = true
          break
        case Qt.Key_R:
          wifi.refresh()
          event.accepted = true
          break
        case Qt.Key_F:
          if (count > 0) {
            var n = wifi.networks.get(networkList.currentIndex)
            if (n && n.known) wifi.forget(n.ssid)
          }
          event.accepted = true
          break
        case Qt.Key_Q:
        case Qt.Key_Escape:
          wifiWindow.visible = false
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

        // Wi-Fi icon
        Text {
          id: headerIcon
          text: wifi.powered ? "wifi" : "wifi_off"
          font.pixelSize: Theme.sizeHeaderTitle
          font.family: Theme.iconFont
          color: wifiWindow.headerColor
          Behavior on color { ColorAnimation { duration: 300 } }

          SequentialAnimation on opacity {
            id: blinkAnim
            running: wifi.scanning
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
          }

          Connections {
            target: wifi
            function onScanningChanged() {
              if (!wifi.scanning) headerIcon.opacity = 1.0
            }
          }
        }

        // Title
        Text {
          text: "Wi-Fi"
          font.pixelSize: Theme.sizeHeaderTitle
          font.family: Theme.monoFont
          font.bold: true
          color: wifiWindow.headerColor
          Behavior on color { ColorAnimation { duration: 300 } }
        }

        // Power indicator dot
        Rectangle {
          width: 10
          height: 10
          radius: 5
          Layout.alignment: Qt.AlignVCenter
          color: {
            if (!wifi.powered) return Theme.red
            if (wifi.connected) return Theme.green
            return Theme.accent
          }
          Behavior on color { ColorAnimation { duration: 300 } }

          SequentialAnimation on scale {
            running: wifi.scanning
            loops: Animation.Infinite
            NumberAnimation { to: 1.4; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
          }
        }
      }

      // ── Connected network info ──
      Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.sizeStatusText
        font.family: Theme.monoFont
        color: wifi.connected ? Theme.textSecondary : Theme.textMuted
        text: {
          if (!wifi.connected) return "not connected"
          var s = wifi.connectedSsid || "Unknown"
          s += "  " + signalIcon(wifi.signalStrength) + " " + wifi.signalStrength + "%"
          return s
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
            {k: "p", d: "power"},
            {k: "s", d: "scan"},
            {k: "d", d: "disc"},
            {k: "r", d: "ref"},
            {k: "f", d: "forget"},
            {k: "q", d: "quit"}
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
      // ── Network list ──
      // ══════════════════════════════
      ListView {
        id: networkList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 2
        model: wifi.networks
        currentIndex: 0
        highlightFollowsCurrentItem: true
        keyNavigationEnabled: false

        delegate: Item {
          required property int index
          width: networkList.width
          height: 34

          property bool isCurrent: index === networkList.currentIndex
          property string ssid: wifi.networks.get(index) ? wifi.networks.get(index).ssid : ""
          property int signal: wifi.networks.get(index) ? wifi.networks.get(index).signal : 0
          property string security: wifi.networks.get(index) ? wifi.networks.get(index).security : ""
          property bool isConnected: wifi.networks.get(index) ? wifi.networks.get(index).connected : false
          property bool isKnown: wifi.networks.get(index) ? wifi.networks.get(index).known : false

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

            // Selection cursor
            Text {
              text: isCurrent ? "▸" : " "
              font.pixelSize: Theme.sizeListText
              font.family: Theme.monoFont
              color: Theme.accent
              Layout.preferredWidth: 12
            }

            // Signal strength icon
            Text {
              text: wifiWindow.signalIcon(signal)
              font.pixelSize: Theme.sizeDeviceIcon
              font.family: Theme.iconFont
              color: {
                if (isConnected) return Theme.green
                if (isCurrent) return Theme.accent
                return Theme.textMuted
              }
              Layout.preferredWidth: 20
              Behavior on color { ColorAnimation { duration: 120 } }
            }

            // Lock icon for secured networks
            Text {
              text: wifiWindow.securityIcon(security)
              font.pixelSize: Theme.sizeListText - 2
              font.family: Theme.iconFont
              color: Theme.textMuted
              visible: security !== "Open"
              Layout.preferredWidth: security !== "Open" ? 14 : 0
            }

            // SSID
            Text {
              text: ssid || "Hidden Network"
              font.pixelSize: Theme.sizeListText
              font.family: Theme.monoFont
              color: {
                if (isConnected) return Theme.wifiConnected
                if (isKnown) return Theme.wifiKnown
                if (security === "Open") return Theme.wifiOpen
                return "#88c0d0" // Hardcoded cyan for newly discovered
              }
              elide: Text.ElideRight
              Layout.fillWidth: true
              Behavior on color { ColorAnimation { duration: 120 } }
            }

            // Status Badges
            Row {
              spacing: 4
              Layout.alignment: Qt.AlignVCenter
              Rectangle {
                visible: isConnected
                color: "#a3be8c" // Hardcoded dull green
                radius: 8
                width: 16; height: 16
                antialiasing: true
                Text { text: "C"; font.pixelSize: 10; font.bold: true; color: Theme.bgPrimary; anchors.centerIn: parent }
              }
              Item {
                visible: isKnown
                width: 16; height: 16
                Rectangle {
                  anchors.fill: parent
                  color: "#81a1c1" // Hardcoded dull blue
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
                Text { text: "K"; font.pixelSize: 10; font.bold: true; color: "#81a1c1"; anchors.centerIn: parent }
              }
            }
          }
        }

        // ── Empty state ──
        Column {
          anchors.centerIn: parent
          visible: networkList.count === 0
          spacing: 12

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: !wifi.powered ? "wifi_off" : "wifi"
            font.pixelSize: Theme.sizeEmptyIcon
            font.family: Theme.iconFont
            color: Theme.textDark
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
              if (!wifi.ready) return "detecting backend..."
              if (!wifi.powered) return "wifi off  ·  [p] to enable"
              return "no networks  ·  [s] to scan"
            }
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.sizeEmptyState
            font.family: Theme.monoFont
            color: Theme.textMuted
          }
        }
      }

      // ══════════════════════════════
      // ── Password input row ──
      // ══════════════════════════════
      Rectangle {
        Layout.fillWidth: true
        height: 38
        radius: 6
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.accent
        visible: wifiWindow.passwordMode

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Text {
            text: "lock"
            font.pixelSize: Theme.sizeListText
            font.family: Theme.iconFont
            color: Theme.accent
          }

          TextInput {
            id: pskInput
            Layout.fillWidth: true
            font.pixelSize: Theme.sizeListText
            font.family: Theme.monoFont
            color: Theme.textPrimary
            echoMode: TextInput.Password
            focus: wifiWindow.passwordMode
            clip: true

            onAccepted: {
              if (text.length > 0) {
                wifi.connectWithPassword(wifiWindow.pendingSsid, text)
                text = ""
                wifiWindow.passwordMode = false
              }
            }

            Keys.onEscapePressed: {
              text = ""
              wifiWindow.passwordMode = false
            }
          }

          Text {
            text: wifiWindow.pendingSsid
            font.pixelSize: Theme.sizeStatusText
            font.family: Theme.monoFont
            color: Theme.textMuted
            elide: Text.ElideRight
            Layout.maximumWidth: 120
          }
        }
      }

      // ── Footer ──
      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          text: "wifi"
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.iconFont
          color: Theme.textDark
        }

        Text {
          Layout.fillWidth: true
          text: wifi.device + " · " + wifi.backendName
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.monoFont
          color: Theme.textDark
        }

        Text {
          text: wifi.networks.count + " networks"
          font.pixelSize: Theme.sizeFooter
          font.family: Theme.monoFont
          color: Theme.textDark
        }
      }
    }
  }
}
