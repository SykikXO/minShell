import QtQuick
import QtQuick.Controls
import Quickshell
import "../"
import "../components"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(9).r, Theme.c(9).g, Theme.c(9).b, 0.8)

  // Helper to generate calendar text
  function getCalendarText() {
    let d = new Date();
    let month = d.getMonth();
    let year = d.getFullYear();
    let today = d.getDate();
    let firstDay = new Date(year, month, 1).getDay();
    let daysInMonth = new Date(year, month + 1, 0).getDate();
    let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    
    let headerColor = Theme.c(15);
    let weekColor = Theme.c(3);
    let todayColor = Theme.c(1);
    
    let title = monthNames[month] + " " + year;
    let padding = Math.floor((20 - title.length) / 2);
    let titleStr = "&nbsp;".repeat(Math.max(0, padding)) + title;
    
    let res = "<font color='" + headerColor + "'><b>" + titleStr + "</b></font><br>";
    res += "<font color='" + weekColor + "'>Su&nbsp;Mo&nbsp;Tu&nbsp;We&nbsp;Th&nbsp;Fr&nbsp;Sa</font><br>";
    
    let line = "";
    for (let i = 0; i < firstDay; i++) {
        line += "&nbsp;&nbsp;&nbsp;";
    }
    for (let i = 1; i <= daysInMonth; i++) {
        let str = i < 10 ? "&nbsp;" + i : "" + i;
        if (i === today) {
            str = "<b><u><font color='" + todayColor + "'>" + str + "</font></u></b>";
        }
        line += str + "&nbsp;";
        if ((i + firstDay) % 7 === 0) {
            res += line.replace(/(?:&nbsp;)+$/, "") + "<br>";
            line = "";
        }
    }
    if (line !== "") res += line.replace(/(?:&nbsp;)+$/, "");
    return res;
  }

  Timer {
    interval: hover.hovered ? 500 : 5000
    running: true
    repeat: true
    onTriggered: {
      let d = new Date();
      timeText.text = Qt.formatDateTime(d, "hh\nmm");
    }
  }

  content: Item {
    width: parent.width
    height: col.height

    Column {
      id: col
      anchors.centerIn: parent
      spacing: 2
      
      Text {
        id: timeText
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Theme.barFont
        font.pixelSize: 22
        color: hover.hovered ? Theme.c(15) : Theme.textPrimary
        text: Qt.formatDateTime(new Date(), "hh\nmm")
        horizontalAlignment: Text.AlignHCenter
      }
    }
    
    HoverHandler { id: hover }

    SidebarTooltip {
      text: root.getCalendarText()
      visible: hover.hovered
      targetItem: col
    }
  }
}
