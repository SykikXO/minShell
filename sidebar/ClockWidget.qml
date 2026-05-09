import QtQuick
import QtQuick.Controls
import Quickshell
import "../"

SidebarWidget {
  id: root
  bgColor: Qt.rgba(Theme.c(9).r, Theme.c(9).g, Theme.c(9).b, 0.8)
  borderColor: Qt.rgba(Theme.c(6).r, Theme.c(6).g, Theme.c(6).b, 1)
  borderStyle: 1 // solid

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
      ampmText.text = Qt.formatDateTime(d, "AP");
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
        font.pixelSize: 20
        color: hover.hovered ? Theme.c(15) : Theme.textPrimary
        text: Qt.formatDateTime(new Date(), "hh\nmm")
        horizontalAlignment: Text.AlignHCenter
      }
      
      Text {
        id: ampmText
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Theme.barFont
        font.pixelSize: 14
        color: hover.hovered ? Theme.c(15) : Theme.textSecondary
        text: Qt.formatDateTime(new Date(), "AP")
      }
    }
    
    HoverHandler { id: hover }

    PopupWindow {
      id: clockToolTip
      visible: hover.hovered
      color: "transparent"
      implicitWidth: contentRect.implicitWidth
      implicitHeight: contentRect.implicitHeight
      anchor {
        item: root
        edges: Edges.Right
        gravity: Edges.Right
        margins.left: Theme.tooltipOffset
      }

      Rectangle {
        id: contentRect
        color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
        border.color: Theme.c(6)
        border.width: 1
        radius: 4
        implicitWidth: textItem.implicitWidth + 20
        implicitHeight: textItem.implicitHeight + 20

        Text {
          id: textItem
          anchors.centerIn: parent
          text: root.getCalendarText()
          textFormat: Text.RichText
          font.family: Theme.monoFont
          font.pixelSize: 16
          color: Theme.textPrimary
        }
      }
    }
  }
}
