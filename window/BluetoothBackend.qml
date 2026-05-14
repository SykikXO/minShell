import Quickshell
import Quickshell.Io
import QtQuick
import "../"

QtObject {
  id: backend

  // ── Public state ──
  property bool   ready: false
  property bool   powered: false
  property bool   discovering: false
  property string adapterName: ""
  property bool   connected: false
  property string connectedDeviceName: ""
  property string connectedDeviceAddress: ""

  property ListModel devices: ListModel {}

  // ── Track true paired state (BlueZ unpairs on disconnect for some headsets) ──
  property var _knownPaired: ({})

  // ── Detect bluetoothctl at startup ──
  property var _detectProc: Process {
    command: ["which", "bluetoothctl"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        if (this.text.trim().length > 0) {
          backend.ready = true
          backend._rebuildAll()
        } else {
          console.warn("BluetoothBackend: bluetoothctl not found")
        }
      }
    }
  }

  // ── Single subprocess refresh for ALL state ──
  function _rebuildAll() {
    _refreshProc.command = ["bash", "-c",
      "echo '===ADAPTER==='; bluetoothctl show 2>/dev/null; " +
      "echo '===DEVICES==='; bluetoothctl -- devices 2>/dev/null; " +
      "echo '===PAIRED==='; bluetoothctl -- devices Paired 2>/dev/null; " +
      "echo '===CONNECTED==='; bluetoothctl -- devices Connected 2>/dev/null; " +
      "echo '===TRUSTED==='; bluetoothctl -- devices Trusted 2>/dev/null"
    ]
    _refreshProc.running = true
  }

  property var _refreshProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._parseRefresh(this.text)
    }
  }

  property var _rebuildTimer: Timer {
    interval: 1000
    running: false
    repeat: true
    onTriggered: backend._rebuildAll()
  }

  onReadyChanged: { if (ready) _rebuildTimer.running = true }

  // ── Parse refresh output ──
  function _parseRefresh(text) {
    var pairedSet = {}
    var connectedSet = {}
    var trustedSet = {}
    var deviceLines = []
    var currentSection = ""
    var lines = text.split("\n")

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (line === "===ADAPTER===") { currentSection = "adapter"; continue }
      if (line === "===DEVICES===") { currentSection = "devices"; continue }
      if (line === "===PAIRED===") { currentSection = "paired"; continue }
      if (line === "===CONNECTED===") { currentSection = "connected"; continue }
      if (line === "===TRUSTED===") { currentSection = "trusted"; continue }

      if (currentSection === "adapter") {
        var t = line.trim()
        if (t.indexOf("Powered:") >= 0) backend.powered = t.indexOf("yes") >= 0
        if (t.indexOf("Discovering:") >= 0) backend.discovering = t.indexOf("yes") >= 0
        if ((t.indexOf("Name:") === 0 || t.indexOf("Alias:") === 0)) {
          var v = t.split(":").slice(1).join(":").trim()
          if (v.length > 0) backend.adapterName = v
        }
      } else if (currentSection === "devices") {
        if (line.indexOf("Device ") === 0) deviceLines.push(line)
      } else if (currentSection === "paired") {
        if (line.indexOf("Device ") === 0) {
          var addr = line.split(/\s+/)[1]
          if (addr) pairedSet[addr.toUpperCase()] = true
        }
      } else if (currentSection === "connected") {
        if (line.indexOf("Device ") === 0) {
          var a = line.split(/\s+/)[1]
          if (a) connectedSet[a.toUpperCase()] = true
        }
      } else if (currentSection === "trusted") {
        if (line.indexOf("Device ") === 0) {
          var addr = line.split(/\s+/)[1]
          if (addr) trustedSet[addr.toUpperCase()] = true
        }
      }
    }

    var addrs = {}
    var newList = []
    for (var j = 0; j < deviceLines.length; j++) {
      var parts = deviceLines[j].split(/\s+/)
      if (parts.length < 3) continue
      var addr2 = parts[1].toUpperCase()
      if (addrs[addr2]) continue
      addrs[addr2] = true
      var name2 = parts.slice(2).join(" ")
      var isCon = !!connectedSet[addr2]
      var isPd = !!pairedSet[addr2]
      if (isPd) backend._knownPaired[addr2] = true
      newList.push({
        address: addr2,
        name: name2,
        connected: isCon,
        paired: isPd || !!backend._knownPaired[addr2],
        trusted: !!trustedSet[addr2],
        icon: ""
      })
    }

    newList.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0))

    devices.clear()
    for (var k = 0; k < newList.length; k++) {
      devices.append(newList[k])
    }

    var found = false
    for (var m = 0; m < newList.length; m++) {
      if (newList[m].connected) {
        backend.connected = true
        backend.connectedDeviceName = newList[m].name
        backend.connectedDeviceAddress = newList[m].address
        found = true
        break
      }
    }
    if (!found) {
      backend.connected = false
      backend.connectedDeviceName = ""
      backend.connectedDeviceAddress = ""
    }
  }

  // ── Write operations (fully bluetoothctl) ──
  function scan() {
    _scanProc.running = true
    backend.discovering = true
  }

  function connectDevice(address) {
    _connectProc.command = ["bluetoothctl", "--", "connect", address]
    _connectProc.running = true
  }

  function disconnectDevice(address) {
    _disconnectProc.command = ["bluetoothctl", "--", "disconnect", address]
    _disconnectProc.running = true
  }

  function pairDevice(address) {
    _pairProc.command = ["bluetoothctl", "--", "pair", address]
    _pairProc.running = true
  }

  function trustDevice(address, trust) {
    if (trust) {
      _trustProc.command = ["bluetoothctl", "--", "trust", address]
    } else {
      _trustProc.command = ["bluetoothctl", "--", "untrust", address]
    }
    _trustProc.running = true
  }

  function forgetDevice(address) {
    delete backend._knownPaired[address.toUpperCase()]
    _forgetProc.command = ["bluetoothctl", "--", "remove", address]
    _forgetProc.running = true
  }

  function togglePower() {
    if (powered) {
      _powerProc.command = ["bluetoothctl", "--", "power", "off"]
    } else {
      _powerProc.command = ["bluetoothctl", "--", "power", "on"]
    }
    _powerProc.running = true
  }

  property var _scanProc: Process {
    command: ["bash", "-c", "timeout 3 bluetoothctl -- scan on 2>/dev/null"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend.discovering = false
        backend._rebuildDelayed.running = true
      }
    }
  }

  property var _connectProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._normalizeBtVolume.running = true
        backend._rebuildDelayed.running = true
      }
    }
  }

  property var _normalizeBtVolume: Process {
    command: ["bash", "-c",
      "sleep 1.5; " +
      "pactl list sinks short | grep bluez | cut -f1 | " +
      "while read id; do pactl set-sink-volume \"$id\" 30%; done " +
      "2>/dev/null || true"]
    running: false
  }
  property var _disconnectProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._rebuildDelayed.running = true
    }
  }
  property var _pairProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._rebuildDelayed.running = true
    }
  }
  property var _trustProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._rebuildDelayed.running = true
    }
  }
  property var _forgetProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._rebuildDelayed.running = true
    }
  }

  property var _powerProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: backend._rebuildDelayed.running = true
    }
  }

  property var _rebuildDelayed: Timer {
    interval: 800
    repeat: false
    onTriggered: backend._rebuildAll()
  }
}
