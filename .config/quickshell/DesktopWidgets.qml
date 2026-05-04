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
//   │                           ▮ INT  ████████ 78% │
//   │                           ▮ EXT  ████░░░░ 43% │
//   └───────────────────────────────────────────────┘

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    color: "#000000"

    // ── Palette ────────────────────────────────────────────────────────────
    readonly property string colWhite:      "#ffffff"
    readonly property string colDimWhite:   "#444444"
    readonly property string colBlue:       "#78b4f3"
    readonly property string colDimBlue:    "#3a5573"
    readonly property string colCyan:       "#ab9df2"
    readonly property string colDimCyan:    "#524a73"
    readonly property string colGreen:      "#a9dc76"
    readonly property string colRed:        "#ff6188"

    readonly property string fontNormal:    "Iosevka Vixelated"
    readonly property string fontCondensed: "Iosevka Vixelated Condensed"
    readonly property int    margin:        24

    // ── Data sources ───────────────────────────────────────────────────────

    // CPU usage — read /proc/stat twice, compute delta
    property real cpuUsage: 0
    property var  _cpuPrev: null

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                const parts = line.trim().split(/\s+/)
                const user   = parseInt(parts[1])
                const nice   = parseInt(parts[2])
                const system = parseInt(parts[3])
                const idle   = parseInt(parts[4])
                const iowait = parseInt(parts[5])
                const irq    = parseInt(parts[6])
                const softirq= parseInt(parts[7])
                const total  = user + nice + system + idle + iowait + irq + softirq
                const used   = total - idle - iowait
                if (root._cpuPrev) {
                    const dt  = total - root._cpuPrev.total
                    const du  = used  - root._cpuPrev.used
                    root.cpuUsage = dt > 0 ? Math.round(du / dt * 100) : 0
                }
                root._cpuPrev = { total: total, used: used }
            }
        }
    }

    // RAM usage — read /proc/meminfo
    property real ramUsage: 0

    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        running: false
        property int memTotal: 0
        property int memAvail: 0
        stdout: SplitParser {
            onRead: function(line) {
                const m = line.match(/^(\w+):\s+(\d+)/)
                if (!m) return
                if (m[1] === "MemTotal")     ramProc.memTotal = parseInt(m[2])
                if (m[1] === "MemAvailable") {
                    ramProc.memAvail = parseInt(m[2])
                    if (ramProc.memTotal > 0)
                        root.ramUsage = Math.round((1 - ramProc.memAvail / ramProc.memTotal) * 100)
                }
            }
        }
    }

    // Battery (INT = BAT0, EXT = BAT1)
    property int  batIntPct:      0
    property bool batIntCharging: false
    property int  batExtPct:      0
    property bool batExtCharging: false
    property bool batExtPresent:  false

    Process {
        id: batIntProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null; " +
            "cat /sys/class/power_supply/BAT0/status 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                batIntProc.lineNum++
                if (batIntProc.lineNum === 1) root.batIntPct = parseInt(line) || 0
                if (batIntProc.lineNum === 2) root.batIntCharging = (line.trim() === "Charging")
            }
        }
        onRunningChanged: if (!running) batIntProc.lineNum = 0
    }

    Process {
        id: batExtProc
        command: ["bash", "-c",
            "[ -d /sys/class/power_supply/BAT1 ] && echo present; " +
            "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null; " +
            "cat /sys/class/power_supply/BAT1/status 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                batExtProc.lineNum++
                if (batExtProc.lineNum === 1 && line.trim() === "present") root.batExtPresent = true
                if (batExtProc.lineNum === 2) root.batExtPct = parseInt(line) || 0
                if (batExtProc.lineNum === 3) root.batExtCharging = (line.trim() === "Charging")
            }
        }
        onRunningChanged: if (!running) { batExtProc.lineNum = 0; if (!running) {} }
    }

    // Network — active connection name and signal strength
    property string netName:   "—"
    property int    netSignal: 0  // 0-100

    Process {
        id: netProc
        // nmcli -t: machine-readable; fields: DEVICE,SIGNAL,ACTIVE,SSID
        command: ["bash", "-c",
            "nmcli -t -f DEVICE,SIGNAL,ACTIVE,SSID device wifi list 2>/dev/null | grep ':yes:' | head -1"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.split(":")
                if (parts.length >= 4) {
                    root.netSignal = parseInt(parts[1]) || 0
                    root.netName   = parts.slice(3).join(":").trim() || parts[0]
                }
            }
        }
    }

    // Tailscale
    property bool tailscaleUp: false

    Process {
        id: tsProc
        command: ["bash", "-c", "tailscale status --json 2>/dev/null | grep -q '\"BackendState\":\"Running\"' && echo up || echo down"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                root.tailscaleUp = (line.trim() === "up")
            }
        }
    }

    // ── Refresh timer ──────────────────────────────────────────────────────
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running  = true
            ramProc.running  = true
            batIntProc.running = true
            batExtProc.running = true
            netProc.running  = true
            tsProc.running   = true
        }
    }

    // ── Clock timer ────────────────────────────────────────────────────────
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockTime.text = Qt.formatTime(new Date(), "HH:mm")
            clockDate.text = Qt.formatDate(new Date(), "ddd · d MMM")
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────
    function barStr(pct) {
        const filled = Math.round(pct / 100 * 8)
        return "█".repeat(filled) + "░".repeat(8 - filled)
    }

    function batColor(pct, charging) {
        return (pct <= 15 && !charging) ? root.colRed : root.colGreen
    }

    // ── UI ─────────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        // Top-right: clock
        Column {
            anchors {
                top:    parent.top
                right:  parent.right
                margins: root.margin
            }
            spacing: 2

            Text {
                id: clockTime
                anchors.right: parent.right
                font.family:   root.fontNormal
                font.pixelSize: 48
                color: root.colWhite
            }

            Text {
                id: clockDate
                anchors.right: parent.right
                font.family:   root.fontNormal
                font.pixelSize: 24
                color: root.colWhite
            }
        }

        // Bottom-left: CPU + RAM
        Column {
            anchors {
                bottom: parent.bottom
                left:   parent.left
                margins: root.margin
            }
            spacing: 4

            // CPU row
            Row {
                spacing: 6
                Text {
                    text: "CPU"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 60
                }
                Text {
                    text: root.barStr(root.cpuUsage)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colBlue
                }
                Text {
                    text: " " + root.cpuUsage + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                }
            }

            // RAM row
            Row {
                spacing: 6
                Text {
                    text: "RAM"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 60
                }
                Text {
                    text: root.barStr(root.ramUsage)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colCyan
                }
                Text {
                    text: " " + root.ramUsage + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                }
            }
        }

        // Bottom-right: tailscale, network, batteries
        Column {
            anchors {
                bottom: parent.bottom
                right:  parent.right
                margins: root.margin
            }
            spacing: 4

            // Network
            Row {
                anchors.right: parent.right
                spacing: 6
                Text {
                    text: root.netName
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                }
                Text {
                    text: root.barStr(root.netSignal)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colGreen
                }
                Text {
                    text: " " + root.netSignal + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 60
                }
            }

            // INT battery
            Row {
                anchors.right: parent.right
                spacing: 6
                Text {
                    text: "INT"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                }
                Text {
                    text: root.barStr(root.batIntPct)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.batColor(root.batIntPct, root.batIntCharging)
                }
                Text {
                    text: " " + root.batIntPct + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 60
                }
            }

            // EXT battery (only shown when present)
            Row {
                anchors.right: parent.right
                spacing: 6
                visible: root.batExtPresent
                Text {
                    text: "EXT"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                }
                Text {
                    text: root.barStr(root.batExtPct)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.batColor(root.batExtPct, root.batExtCharging)
                }
                Text {
                    text: " " + root.batExtPct + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 60
                }
            }
        }
    }
}
