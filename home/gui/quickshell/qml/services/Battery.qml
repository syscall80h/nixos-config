pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Battery percentage / charging state. present is false when no battery exists.
Singleton {
  id: root

  property bool present: false
  property int percent: 0
  property bool charging: false

  // Async loading would leave text() empty right after reload(), so the first poll
  // would always report no battery. sysfs reads are tiny, so just block on them.
  FileView { id: capacityFile; path: "/sys/class/power_supply/BAT0/capacity"; blockLoading: true }
  FileView { id: statusFile; path: "/sys/class/power_supply/BAT0/status"; blockLoading: true }

  function _update() {
    capacityFile.reload();
    statusFile.reload();

    const cap = parseInt(capacityFile.text());
    root.present = !isNaN(cap);
    if (root.present) {
      root.percent = cap;
      root.charging = statusFile.text().trim() === "Charging";
    }
  }

  Timer {
    interval: 10000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: root._update()
  }
}
