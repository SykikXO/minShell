pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: theme

    // ── Fonts ──
    property string iconFont: "Material Symbols Rounded"
    property string monoFont: "Iosevka Nerd Font Mono"
    property string barFont: "Iosevka Nerd Font Mono"

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
    property int sizeIcon: 22

    // ── Layout & Offsets ──
    property int tooltipOffset: 36

    // ── Pywal colors (loaded from ~/.cache/wal/colors.json) ──
    property var _wal: null

    property color bgPrimary: _wal ? _wal.special.background : "#0e1412"
    property color bgSecondary: _wal ? Qt.lighter(_wal.special.background, 1.15) : "#162220"
    property color bgTertiary: _wal ? Qt.lighter(_wal.special.background, 1.25) : "#1e302c"
    property color bgHover: _wal ? Qt.lighter(_wal.special.background, 1.35) : "#284038"
    property color borderColor: _wal ? _wal.colors.color8 : "#4a5a54"
    property color textPrimary: _wal ? _wal.special.foreground : "#c1c4c3"
    property color textSecondary: _wal ? _wal.colors.color7 : "#9ba19e"
    property color textMuted: _wal ? _wal.colors.color8 : "#6b7674"
    property color textDark: _wal ? Qt.darker(_wal.colors.color8, 1.4) : "#2d3835"
property color accent: _wal ? _wal.colors.color4 : "#7aa2b9"
    property color accentDark: _wal ? Qt.darker(_wal.colors.color4, 1.5) : "#4d6b82"
    property color toggleOff: _wal ? Qt.darker(_wal.colors.color8, 1.2) : "#2d3835"
    property color white: "#ffffff"

    // ── Semantic colors (always fixed, never from pywal) ──
    property color green: "#4a8c6f"
    property color red: "#c75d68"
    property color orange: "#c98845"
    property color yellow: "#b8a46a"
    property color purple: "#9a7a93"

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
