pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: theme

    // ── Fonts ──
    property string iconFont: "Material Symbols Rounded"
    property string monoFont: "Iosevka Nerd Font Mono"
    property string barFont: "Input Mono Condensed"

    // ── Helper to access numbered colors ──
    function c(num) {
        return _wal && _wal.colors["color" + num] ? _wal.colors["color" + num] : "#ffffff";
    }

    // ── Font Sizes ──
    property int sizeBigHeader: 33
    property int sizeHeaderIcon: 27
    property int sizeHeaderTitle: 23
    property int sizeDeviceIcon: 21
    property int sizeListText: 18
    property int sizeStatusText: 15
    property int sizeEmptyIcon: 53
    property int sizeEmptyState: 17
    property int sizeFooter: 15
    property int sizeBattery: 19

    // ── Layout & Offsets ──
    property int tooltipOffset: 32

    // ── Pywal colors (loaded from ~/.cache/wal/colors.json) ──
    property var _wal: null

    property color bgPrimary: _wal ? _wal.special.background : "#091510"
    property color bgSecondary: _wal ? Qt.lighter(_wal.special.background, 1.15) : "#112019"
    property color bgTertiary: _wal ? Qt.lighter(_wal.special.background, 1.25) : "#192a22"
    property color bgHover: _wal ? Qt.lighter(_wal.special.background, 1.35) : "#21342c"
    property color borderColor: _wal ? _wal.colors.color8 : "#586c63"
    property color textPrimary: _wal ? _wal.special.foreground : "#c1c4c3"
    property color textSecondary: _wal ? _wal.colors.color7 : "#8d9793"
    property color textMuted: _wal ? _wal.colors.color8 : "#586c63"
    property color textDark: _wal ? Qt.darker(_wal.colors.color8, 1.4) : "#3b4b43"
    property color accent: _wal ? _wal.colors.color4 : "#62747c"
    property color accentDark: _wal ? Qt.darker(_wal.colors.color4, 1.5) : "#3d59a1"
    property color green: _wal ? _wal.colors.color2 : "#27843f"
    property color red: _wal ? _wal.colors.color1 : "#475868"
    property color lightBlue: _wal ? _wal.colors.color12 : "#67a2bd"
    property color toggleOff: _wal ? Qt.darker(_wal.colors.color8, 1.2) : "#3b4b43"
    property color white: "#ffffff"

    // ── Device state colors (matched to pywal) ──
    property color devConnected: textPrimary
    property color devPaired: textSecondary
    property color devTrusted: accent
    property color devDiscovered: textMuted

    // ── Wi-Fi state colors ──
    property color wifiConnected: textPrimary
    property color wifiKnown: textSecondary
    property color wifiOpen: textSecondary
    property color wifiNew: textMuted

    // ── Load pywal JSON via Process ──
    property string _lastWalText: ""

    property var _reader: Process {
        command: ["cat", Quickshell.env("HOME") + "/.cache/wal/colors.json"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (this.text !== theme._lastWalText) {
                        theme._lastWalText = this.text;
                        theme._wal = JSON.parse(this.text);
                    }
                } catch (e) {
                    console.warn("Theme: could not parse pywal colors.json:", e);
                }
            }
        }
    }
}
