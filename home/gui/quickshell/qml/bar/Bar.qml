import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.components
import qs.services
import qs.theme

PanelWindow {
  id: bar

  required property var modelData

  // A mapped layer-shell surface on a monitor forces Hyprland to fully composite
  // every frame there instead of direct-scanning out a fullscreen client, which is
  // a real GPU cost (not just a tearing-eligibility check). Unmap the bar on any
  // monitor currently showing a fullscreen window so scanout can take over.
  readonly property bool fullscreenActive: Hyprland.toplevels.values.some(
    t => t.monitor?.name === Hyprland.monitorFor(modelData)?.name && t.lastIpcObject.fullscreen === 2
  )

  screen: modelData
  visible: !fullscreenActive
  color: "transparent"
  implicitHeight: Theme.barHeight
  anchors { top: true; left: true; right: true }

  readonly property real leftWidth: title.visible ? title.width : 0
  readonly property real rightWidth: rightSection.width

  // Left
  WindowTitle {
    id: title

    // Only claim what the centre and right sections leave over, so a long window
    // title elides instead of sliding underneath them.
    maxWidth: bar.width - bar.rightWidth - centerSection.width - 4 * Theme.gap - 24
    anchors { left: parent.left; leftMargin: Theme.gap; verticalCenter: parent.verticalCenter }
  }

  // Center: centred in the gap between the side sections rather than in the whole
  // bar, so it drifts off true centre instead of overlapping when a side gets wide.
  Item {
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left; leftMargin: bar.leftWidth + 2 * Theme.gap
      right: parent.right; rightMargin: bar.rightWidth + 2 * Theme.gap
    }
    implicitHeight: centerSection.height

    Row {
      id: centerSection
      anchors.centerIn: parent
      spacing: Theme.gap

      Workspaces { monitor: Hyprland.monitorFor(bar.modelData) }
    }
  }

  // Right
  Row {
    id: rightSection
    anchors { right: parent.right; rightMargin: Theme.gap; verticalCenter: parent.verticalCenter }
    spacing: Theme.gap

    Tray { window: bar }
    Stat { icon: ""
      value: Stats.cpu + "%"
      onClicked: cpuProc.running = true

      Process {
        id: cpuProc
        command: ["uwsm", "app", "--", "kitty", "btop"]
      }
    }
    Stat { icon: ""
      value: Stats.mem + "%"
      onClicked: memProc.running = true

      Process {
        id: memProc
        command: ["uwsm", "app", "--", "kitty", "sh", "-c", "btop -c $HOME/.config/btop/mem.conf"]
      }
    }
    NetworkSpeed {
      onClicked: nmtuiProc.running = true

      Process {
        id: nmtuiProc
        command: ["uwsm", "app", "--", "kitty", "nmtui"]
      }
    }
    Volume {}
    Stat {
      visible: Battery.present
      icon: Battery.charging ? "" : Battery.percent >= 90 ? "" : Battery.percent >= 65 ? "" : Battery.percent >= 40 ? "" : Battery.percent >= 15 ? "" : ""
      value: Battery.percent + "%"
    }
    Clock {}
  }
}
