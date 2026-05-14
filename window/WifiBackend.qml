import Quickshell
import Quickshell.Io
import QtQuick
import "../"

QtObject {
  id: backend

  // ── Public state ──
  property bool   ready: false
  property string backendName: ""
  property string device: "wlan0"
  property bool   powered: false
  property bool   scanning: false
  property bool   connected: false
  property string connectedSsid: ""
  property int    signalStrength: 0

  // ── Network list model ──
  // Each entry: { ssid, signal, security, connected, known }
  property ListModel networks: ListModel {}

  // ── Error state ──
  property string connectionError: ""

  // ── Internal ──
  property bool _useIwctl: false
  property bool _useNmcli: false
  property var  _pendingPsk: null   // { ssid, psk } for deferred connect

  // Shell-escape a string for use in bash -c
  function _shquote(s) {
    return "'" + String(s).replace(/'/g, "'\\''") + "'"
  }

  // ══════════════════════════════════════════
  // ── Backend detection at startup ──
  // ══════════════════════════════════════════
  property var _detectIwctl: Process {
    command: ["which", "iwctl"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        if (this.text.trim().length > 0) {
          backend._useIwctl = true
          backend.backendName = "iwctl"
          backend.ready = true
          backend._detectDevice()
        } else {
          backend._detectNmcliProc.running = true
        }
      }
    }
  }

  property var _detectNmcliProc: Process {
    command: ["which", "nmcli"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        if (this.text.trim().length > 0) {
          backend._useNmcli = true
          backend.backendName = "nmcli"
          backend.ready = true
          backend._detectDevice()
        } else {
          console.warn("WifiBackend: neither iwctl nor nmcli found")
        }
      }
    }
  }

  // ── Detect interface name ──
  function _detectDevice() {
    if (_useIwctl) {
      _deviceDetectProc.command = ["bash", "-c", "iwctl device list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/station/{print $1; exit}'"]
    } else {
      _deviceDetectProc.command = ["bash", "-c", "nmcli -t -f DEVICE,TYPE device | awk -F: '/wifi/{print $1; exit}'"]
    }
    _deviceDetectProc.running = true
  }

  property var _deviceDetectProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        var d = this.text.trim()
        if (d.length > 0) backend.device = d
        backend.refresh()
      }
    }
  }

  // ══════════════════════════════════════════
  // ── Public API ──
  // ══════════════════════════════════════════

  function scan() {
    backend.scanning = true
    if (_useIwctl) {
      _scanProc.command = ["iwctl", "station", device, "scan"]
    } else {
      _scanProc.command = ["bash", "-c", "nmcli device wifi rescan 2>/dev/null; echo done"]
    }
    _scanProc.running = true
  }

  function refresh() {
    _refreshStatus()
    _refreshNetworks()
  }

  function connect(ssid) {
    backend.connectionError = ""
    if (_useIwctl) {
      _connectProc.command = ["iwctl", "station", device, "connect", ssid]
    } else {
      _connectProc.command = ["bash", "-c", "nmcli device wifi connect " + _shquote(ssid)]
    }
    _connectProc.running = true
  }

  function connectWithPassword(ssid, psk) {
    backend.connectionError = ""
    if (_useIwctl) {
      _connectProc.command = ["iwctl", "--passphrase", psk, "station", device, "connect", ssid]
    } else {
      _connectProc.command = ["bash", "-c", "nmcli device wifi connect " + _shquote(ssid) + " password " + _shquote(psk)]
    }
    _connectProc.running = true
  }

  function disconnect() {
    backend.connectionError = ""
    if (_useIwctl) {
      _disconnectProc.command = ["iwctl", "station", device, "disconnect"]
    } else {
      _disconnectProc.command = ["bash", "-c", "nmcli device disconnect " + _shquote(device)]
    }
    _disconnectProc.running = true
  }

  function forget(ssid) {
    if (_useIwctl) {
      _forgetProc.command = ["iwctl", "known-networks", ssid, "forget"]
    } else {
      _forgetProc.command = ["bash", "-c", "nmcli connection delete id " + _shquote(ssid)]
    }
    _forgetProc.running = true
  }

  function togglePower() {
    if (_useIwctl) {
      // iwctl uses rfkill or adapter power
      var cmd = powered
        ? "rfkill block wifi"
        : "rfkill unblock wifi"
      _powerProc.command = ["bash", "-c", cmd]
    } else {
      _powerProc.command = ["nmcli", "radio", "wifi", powered ? "off" : "on"]
    }
    _powerProc.running = true
  }

  // ══════════════════════════════════════════
  // ── Internal processes ──
  // ══════════════════════════════════════════

  // ── Scan process ──
  property var _scanProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        // iwctl scan is async; wait briefly then fetch results
        backend._scanTimer.running = true
      }
    }
  }

  property var _scanTimer: Timer {
    interval: 3000
    repeat: false
    onTriggered: {
      backend.scanning = false
      backend._refreshNetworks()
    }
  }

  // ── Connect process ──
  property var _connectProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._refreshDelayed.running = true
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        var err = this.text.trim()
        if (err.length > 0) {
          backend.connectionError = err
          console.warn("WifiBackend connect error:", err)
        }
      }
    }
  }

  // ── Disconnect process ──
  property var _disconnectProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._refreshDelayed.running = true
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        var err = this.text.trim()
        if (err.length > 0) console.warn("WifiBackend disconnect error:", err)
      }
    }
  }

  // ── Forget process ──
  property var _forgetProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._refreshNetworks()
      }
    }
  }

  // ── Power toggle process ──
  property var _powerProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._refreshDelayed.running = true
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        var err = this.text.trim()
        if (err.length > 0) console.warn("WifiBackend power error:", err)
      }
    }
  }

  // ── Delayed refresh (give daemons time to react) ──
  property var _refreshDelayed: Timer {
    interval: 1500
    repeat: false
    onTriggered: backend.refresh()
  }

  // ══════════════════════════════════════════
  // ── Status refresh ──
  // ══════════════════════════════════════════

  function _refreshStatus() {
    if (_useIwctl) {
      _statusProc.command = ["bash", "-c",
        "iwctl station " + device + " show 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g'"
      ]
    } else {
      _statusProc.command = ["bash", "-c",
        "nmcli -t -f WIFI radio; nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION device show '" + device + "' 2>/dev/null"
      ]
    }
    _statusProc.running = true
  }

  property var _statusProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._parseStatus(this.text)
      }
    }
  }

  function _parseStatus(text) {
    if (_useIwctl) {
      // Parse "iwctl station <dev> show" output
      var lines = text.split("\n")
      var state = ""
      var ssid = ""
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim()
        // Match "State                 connected" but not "Station:" header
        if (line.indexOf("State") === 0 && line.indexOf("Station") < 0) {
          var parts = line.split(/\s{2,}/)
          if (parts.length >= 2) state = parts[parts.length - 1].trim().toLowerCase()
        }
        if (line.indexOf("Connected network") === 0) {
          var parts2 = line.split(/\s{2,}/)
          if (parts2.length >= 2) ssid = parts2[parts2.length - 1].trim()
        }
      }
      powered = (state !== "" && state !== "powered off" && state.indexOf("unavail") < 0)
      connected = (state === "connected")
      connectedSsid = connected ? ssid : ""
    } else {
      // Parse nmcli output
      var lines2 = text.split("\n")
      if (lines2.length > 0) {
        powered = (lines2[0].trim().toLowerCase() === "enabled")
      }
      var stateConnected = false
      var stateSsid = ""
      for (var j = 1; j < lines2.length; j++) {
        var l = lines2[j]
        if (l.indexOf("GENERAL.STATE") >= 0) {
          var stateVal = l.split(":").slice(1).join(":").trim()
          // nmcli state: 100 = connected, 70 = connecting, 30 = disconnected
          var stateNum = parseInt(stateVal)
          stateConnected = (stateNum === 100)
        }
        if (l.indexOf("GENERAL.CONNECTION") >= 0) {
          stateSsid = l.split(":").slice(1).join(":").trim()
        }
      }
      connected = stateConnected
      connectedSsid = connected && stateSsid !== "--" ? stateSsid : ""
      if (connected || stateSsid === "--") backend.connectionError = ""
    }
  }

  // ══════════════════════════════════════════
  // ── Network list refresh ──
  // ══════════════════════════════════════════

  function _refreshNetworks() {
    if (_useIwctl) {
      // Get networks and known-networks (strip ANSI codes from iwctl output)
      _networkProc.command = ["bash", "-c",
        "echo '===NETWORKS==='; iwctl station " + device + " get-networks 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g'; echo '===KNOWN==='; iwctl known-networks list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g'"
      ]
    } else {
      _networkProc.command = ["bash", "-c",
        "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null; echo '===KNOWN==='; nmcli -t -f NAME connection show 2>/dev/null"
      ]
    }
    _networkProc.running = true
  }

  property var _networkProc: Process {
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        backend._parseNetworks(this.text)
      }
    }
  }

  function _parseNetworks(text) {
    networks.clear()

    if (_useIwctl) {
      _parseIwctlNetworks(text)
    } else {
      var sections = text.split("===KNOWN===")
      var knownSsids = {}
      var knownLines = (sections.length > 1 ? sections[1] : "").split("\n")
      for (var k = 0; k < knownLines.length; k++) {
        var kl = knownLines[k].trim()
        if (kl.length > 0) knownSsids[kl] = true
      }
      _parseNmcliNetworks(sections[0], knownSsids)
    }
  }

  function _parseIwctlNetworks(text) {
    // Split into networks section and known section
    var sections = text.split("===KNOWN===")
    var netSection = sections.length > 0 ? sections[0] : ""
    var knownSection = sections.length > 1 ? sections[1] : ""

    // Parse known networks list
    var knownSsids = {}
    var knownLines = knownSection.split("\n")
    for (var k = 0; k < knownLines.length; k++) {
      var kl = knownLines[k].trim()
      // Skip header/separator lines
      if (kl.length === 0 || kl.indexOf("---") >= 0 || kl.indexOf("Known") >= 0
          || kl.indexOf("Name") >= 0)
        continue
      // Known networks format: "  NetworkName    date"
      // The SSID is the first non-empty field
      var kParts = kl.split(/\s{2,}/)
      if (kParts.length >= 1) {
        var kssid = kParts[0].trim()
        if (kssid.length > 0) knownSsids[kssid] = true
      }
    }

    // Parse scan results from "get-networks"
    // Lines look like:  "  > NetworkName     psk   ****  " or "    NetworkName     psk   ****"
    // The > indicates currently connected
    var netLines = netSection.split("\n")
    var seenSsids = {}
    var tempNetworks = []
    for (var i = 0; i < netLines.length; i++) {
      var rawLine = netLines[i]
      // Skip headers, separators, section markers
      if (rawLine.indexOf("===") >= 0 || rawLine.indexOf("---") >= 0
          || rawLine.indexOf("Available") >= 0 || rawLine.indexOf("Network name") >= 0
          || rawLine.trim().length === 0)
        continue

      // Detect connected marker
      var isConnected = (rawLine.indexOf(">") >= 0)
      // Remove the > marker for parsing (ANSI already stripped by sed)
      var cleaned = rawLine.replace(">", " ")

      // Split on 2+ spaces
      var parts = cleaned.trim().split(/\s{2,}/)
      if (parts.length < 2) continue

      var ssid = parts[0].trim()
      if (ssid.length === 0 || seenSsids[ssid]) continue
      seenSsids[ssid] = true

      var security = parts.length >= 2 ? parts[1].trim() : "Open"

      // Signal: iwctl shows stars (****/****) — count filled stars
      var sig = 0
      for (var s = 2; s < parts.length; s++) {
        var field = parts[s].trim()
        if (field.indexOf("*") >= 0) {
          // Count asterisks vs total length for signal percentage
          var stars = (field.match(/\*/g) || []).length
          // iwctl typically shows 4 possible bars
          sig = Math.round((stars / 4) * 100)
          break
        }
      }

      if (isConnected) {
        backend.signalStrength = sig
      }

      tempNetworks.push({
        ssid: ssid,
        signal: sig,
        security: security.toLowerCase() === "open" ? "Open" : security,
        connected: isConnected,
        known: (knownSsids[ssid] === true) || isConnected
      })
    }

    tempNetworks.sort((a, b) => {
      if (a.connected !== b.connected) return a.connected ? -1 : 1
      if (a.known !== b.known) return a.known ? -1 : 1
      if (a.signal !== b.signal) return b.signal - a.signal
      return a.ssid.localeCompare(b.ssid)
    })

    for (var j = 0; j < tempNetworks.length; j++) {
      networks.append(tempNetworks[j])
    }
  }

  function _parseNmcliNetworks(text, knownSsids) {
    // nmcli -t format: IN-USE:SSID:SIGNAL:SECURITY
    var lines = text.split("\n")
    var seenSsids = {}
    var tempNetworks = []
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (line.length === 0) continue

      // -t uses : delimiter — but SSID could contain colons (rare)
      // IN-USE is either "*" or ""
      var inUse = false
      var rest = line
      if (line.charAt(0) === "*") {
        inUse = true
        rest = line.substring(2)  // skip "*:"
      } else if (line.charAt(0) === ":") {
        rest = line.substring(1)
      }

      // Now rest is SSID:SIGNAL:SECURITY
      var lastColon = rest.lastIndexOf(":")
      if (lastColon < 0) continue
      var security = rest.substring(lastColon + 1)
      rest = rest.substring(0, lastColon)

      lastColon = rest.lastIndexOf(":")
      if (lastColon < 0) continue
      var sig = parseInt(rest.substring(lastColon + 1)) || 0
      var ssid = rest.substring(0, lastColon)

      if (ssid.length === 0 || seenSsids[ssid]) continue
      seenSsids[ssid] = true

      if (inUse) backend.signalStrength = sig

      tempNetworks.push({
        ssid: ssid,
        signal: sig,
        security: (security === "" || security === "--") ? "Open" : security,
        connected: inUse,
        known: inUse || (knownSsids && knownSsids[ssid] === true)
      })
    }

    tempNetworks.sort((a, b) => {
      if (a.connected !== b.connected) return a.connected ? -1 : 1
      if (a.known !== b.known) return a.known ? -1 : 1
      if (a.signal !== b.signal) return b.signal - a.signal
      return a.ssid.localeCompare(b.ssid)
    })

    for (var j = 0; j < tempNetworks.length; j++) {
      networks.append(tempNetworks[j])
    }
  }

  // ══════════════════════════════════════════
  // ── Auto-refresh timer ──
  // ══════════════════════════════════════════
  property var _autoRefresh: Timer {
    interval: 5000
    repeat: true
    running: backend.ready
    onTriggered: backend.refresh()
  }
}
