# minShell

A Quickshell configuration providing a minimal functional sidebar for Hyprland with popup windows for Wi-Fi and Bluetooth management.

## Preview

<p align="center">
  <img src="assets/sidebar-overview.avif" width="100" />&nbsp;&nbsp;
  <img src="assets/sidebar-widgets.avif" width="100" />&nbsp;&nbsp;
  <img src="assets/sidebar-hardware.avif" width="100" />
</p>
<p align="center">
  <img src="assets/sidebar-full.avif" width="600" />
</p>

### Popup Windows

<p align="center">
  <img src="assets/wifi-popup.avif" width="600" />
</p>
<p align="center">
  <img src="assets/bluetooth-popup.avif" width="600" />
</p>

## Features

### Sidebar Widgets
- **Clock** - Real-time clock with calendar popup
- **Workspaces** - Workspace indicators with layout preview
- **Network** - Active connection status
- **Bluetooth** - Connected device status
- **Audio** - Volume control
- **Backlight** - Screen brightness control
- **Battery** - Power status and notifications
- **Notifications** - Notification counter and access
- **Hardware** - CPU, memory, and temperature monitoring
- **Idle** - Idle detection with configurable actions

### Popup Windows
- **Wi-Fi Manager** - Connect to networks using iwd
- **Bluetooth Manager** - Pair and manage devices using BlueZ

## Installation

1. Create a Quickshell config directory:
   ```bash
   mkdir -p ~/.config/quickshell
   ```

2. Clone or copy this repository:
   ```bash
   git clone https://github.com/sykikxo/minshell.git
   mv minshell/* ~/.config/quickshell/
   ```

3. Start Quickshell:
   ```bash
   quickshell
   ```
   Or add to your `hyprland.conf`:
   ```ini
   exec = quickshell
   ```

## Configuration

### Dependencies
- [Quickshell](https://github.com/nicbarker/clatter)
- Hyprland
- iwd (for Wi-Fi)
- BlueZ (for Bluetooth)
- playerctl (for media notifications)

### Theme Customization
Edit `Theme.qml` to customize colors and styling. The theme uses pywal colors for automatic color scheme generation.

### Widget Settings
- Thresholds for warnings (CPU, memory, temperature, battery) are defined in each widget
- Hover tooltips show detailed information when hovering over widgets
- Click actions and keybinds can be configured in the respective widget files

## Architecture

```
quickshell/
├── assets/              # Preview images (avif)
├── shell.qml            # Main entry point
├── Theme.qml            # Shared theme and styling
├── components/          # Reusable UI components
│   ├── SidebarTooltip.qml
│   ├── KeybindBar.qml
│   ├── PopupHeader.qml
│   └── StatusBadge.qml
├── SidebarWindow.qml    # Sidebar container
├── SidebarWidget.qml    # Base widget component
├── sidebar/
│   ├── ClockWidget.qml
│   ├── WorkspacesWidget.qml
│   ├── NetworkWidget.qml
│   ├── BluetoothWidget.qml
│   ├── AudioWidget.qml
│   ├── BacklightWidget.qml
│   ├── BatteryWidget.qml
│   ├── NotificationWidget.qml
│   ├── HardwareWidget.qml
│   └── IdleWidget.qml
└── window/
    ├── KeyboardWindow.qml
    ├── WifiWindow.qml
    ├── BluetoothWindow.qml
    └── WifiBackend.qml
```

## Refactoring Note

This codebase contains several patterns that could be extracted into shared components:
- PopupWindow/Tooltip pattern
- Keybind bar and header/footer patterns
- Status badge components
- System stat reading utilities

See individual widget files for widget-specific configuration options.