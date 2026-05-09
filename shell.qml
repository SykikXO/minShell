import Quickshell
import Quickshell.Io
import "./sidebar"
import "./window"

ShellRoot {
  id: root
  
  IpcHandler {
    target: "shell"
    function bluetooth() { 
      var toShow = !btWin.visible;
      wifiWin.visible = false;
      btWin.visible = toShow;
    }
    function productivity(){
      sideBar.visible = !sideBar.visible;
    }
    function wifi() { 
      var toShow = !wifiWin.visible;
      btWin.visible = false;
      wifiWin.visible = toShow;
    }

    function reloadColors() {
      Theme._reader.running = true;
    }
  }

  SidebarWindow {
    id: sideBar
    visible: true
  }

  BluetoothWindow {
    id: btWin
    visible: false // Start hidden
  }

  WifiWindow {
    id: wifiWin
    visible: false // Start hidden
  }
}
