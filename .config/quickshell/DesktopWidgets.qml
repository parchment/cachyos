// DesktopWidgets.qml
//
// Layout (all edges have 24px margin):
//
//   ┌───────────────────────────────────────────────┐
//   │                                      12:47    │
//   │                                 Mon · 3 May   │
//   │                                               │
//   │  CPU  ████████░░░░  52%   ◈ tailscale         │
//   │  RAM  █████░░░░░░░  31%   ▼ wlan0  ████  87%  │
//   │  TMP  ██████░░░░░░  72°C  ▲ 1.2 MB/s          │
//   │  SWP  ██░░░░░░░░░░   8%   ▼ 340 KB/s           │
//   │                           ▮ INT  ████████ 78% │
//   │                           ▮ EXT  ████░░░░ 43% │
//   └───────────────────────────────────────────────┘

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

        SystemStatsWidget {
            id: sysStats
            anchors {
                bottom:  parent.bottom
                left:    parent.left
                margins: Theme.margin
            }
            cpuSource:      cpu
            ramSource:      ram
            tempSource:     temp
            topProcsSource: topProcs
            diskSource:     disk
        }

        NetworkStatusWidget {
            id: netStatus
            anchors {
                bottom:  parent.bottom
                right:   parent.right
                margins: Theme.margin
            }
            netSource: network
            batSource: battery
        }

        NetworkBarWidget {
            anchors {
                right:        parent.right
                bottom:       netStatus.top
                rightMargin:  Theme.margin
                bottomMargin: Theme.spacerMd
            }
            width: netStatus.width
            netSource: network
        }
    }
}
