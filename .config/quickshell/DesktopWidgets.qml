// DesktopWidgets.qml
//
// Layout (all edges have 24px margin):
//
//   ┌──────────────────────────────────────────────────────────────┐
//   │                                                    12:47     │
//   │                                               Mon · 3 May   │
//   │                                                              │
//   │  52%  ░░████████  CPU                                      │
//   │  31%  ░░░█████░░  C3             ████░░░░ ░░░░████        │
//   │  18%  ░░░░░███░░  C7             ↑ 1.2 MB/s  340 KB/s ↓   │
//   │  31%  ░░░█████░░  RAM                                       │
//   │   8%  ░░░░░░██░░  SWP            firefox                    │
//   │                                   ████░░ ░░░███  12% · 2.1%│
//   │ 72°C  ░░█████░░  TMP             code                       │
//   │                                   ███░░░ ░░░░██   8% · 0.9%│
//   │  64%  ░░████████  /              ...                        │
//   │  41%  ░░░████░░░  /home                                     │
//   │                                                              │
//   │  87%  ░░████████  wlan0                                     │
//   │                                                              │
//   │  78%  ░░████████  INT                                       │
//   │  43%  ░░░████░░░  EXT                                       │
//   └──────────────────────────────────────────────────────────────┘

import QtQuick
import Quickshell
import Quickshell.Wayland
import "sources"
import "widgets"

PanelWindow {
    id: root

    anchors { top: true; left: true; right: true; bottom: true }
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    color: "#000000"

    // ── Data sources ───────────────────────────────────────────────────────
    CpuSource      { id: cpu }
    RamSource      { id: ram }
    CpuTempSource  { id: temp }
    TopProcsSource { id: topProcs }
    DiskSource     { id: disk }
    BatterySource  { id: battery }
    NetworkSource  { id: network }
    TailscaleSource{ id: tailscale }

    // ── Refresh timer ──────────────────────────────────────────────────────
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpu.trigger()
            ram.trigger()
            temp.trigger()
            topProcs.trigger()
            disk.trigger()
            battery.trigger()
            network.trigger()
            tailscale.trigger()
        }
    }

    // ── Layout ─────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        ClockWidget {
            anchors {
                top:    parent.top
                right:  parent.right
                margins: Theme.margin
            }
        }

        TopProcsWidget {
            id: topProcsWgt
            anchors {
                bottom:  parent.bottom
                right:   parent.right
                margins: Theme.margin
            }
            topProcsSource: topProcs
        }

        NetworkBarWidget {
            anchors {
                right:        parent.right
                bottom:       topProcsWgt.top
                rightMargin:  Theme.margin
                bottomMargin: Theme.spacerMd
            }
            width: topProcsWgt.width
            netSource: network
        }

        NetworkStatusWidget {
            id: netStatus
            anchors {
                bottom:  parent.bottom
                left:    parent.left
                margins: Theme.margin
            }
            netSource: network
            batSource: battery
        }

        SysMetricsWidget {
            anchors {
                left:         parent.left
                bottom:       netStatus.top
                leftMargin:   Theme.margin
                bottomMargin: Theme.spacerMd
            }
            cpuSource:  cpu
            ramSource:  ram
            tempSource: temp
            diskSource: disk
        }
    }
}
