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
    property real ramUsage:  0
    property real swapUsage: 0

    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        running: false
        property int memTotal:  0
        property int memAvail:  0
        property int swapTotal: 0
        stdout: SplitParser {
            onRead: function(line) {
                const m = line.match(/^(\w+):\s+(\d+)/)
                if (!m) return
                if (m[1] === "MemTotal")     ramProc.memTotal  = parseInt(m[2])
                if (m[1] === "MemAvailable") {
                    ramProc.memAvail = parseInt(m[2])
                    if (ramProc.memTotal > 0)
                        root.ramUsage = Math.round((1 - ramProc.memAvail / ramProc.memTotal) * 100)
                }
                if (m[1] === "SwapTotal")    ramProc.swapTotal = parseInt(m[2])
                if (m[1] === "SwapFree") {
                    const swapFree = parseInt(m[2])
                    if (ramProc.swapTotal > 0)
                        root.swapUsage = Math.round((1 - swapFree / ramProc.swapTotal) * 100)
                    else
                        root.swapUsage = 0
                }
            }
        }
    }

    // Battery (INT = BAT0, EXT = BAT1)
    // "charging" = AC adapter online; covers "Charging", "Not charging" (TLP threshold), and "Full"
    property int  batIntPct:      0
    property bool batIntCharging: false
    property int  batExtPct:      0
    property bool batExtCharging: false
    property bool batExtPresent:  false

    Process {
        id: batIntProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/AC/online 2>/dev/null; " +
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                batIntProc.lineNum++
                if (batIntProc.lineNum === 1) root.batIntCharging = (line.trim() === "1")
                if (batIntProc.lineNum === 2) root.batIntPct = parseInt(line) || 0
            }
        }
        onRunningChanged: if (!running) batIntProc.lineNum = 0
    }

    Process {
        id: batExtProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/AC/online 2>/dev/null; " +
            "[ -d /sys/class/power_supply/BAT1 ] && echo present; " +
            "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                batExtProc.lineNum++
                if (batExtProc.lineNum === 1) root.batExtCharging = (line.trim() === "1")
                if (batExtProc.lineNum === 2 && line.trim() === "present") root.batExtPresent = true
                if (batExtProc.lineNum === 3) root.batExtPct = parseInt(line) || 0
            }
        }
        onRunningChanged: if (!running) batExtProc.lineNum = 0
    }

    // Network — connection type, signal strength, and throughput
    property string netType:   "NO CONNECTION"   // "WIFI", "ETH", or "NO CONNECTION"
    property int    netSignal: 0     // 0-100, only meaningful for WiFi
    property real   netRxRate: 0     // bytes/sec
    property real   netTxRate: 0     // bytes/sec
    property var    _netPrev:  null  // { rx, tx, time }
    property var    netHistory: []   // [{ rx, tx }, …] — last 60 samples

    Process {
        id: netProc
        // Check for active ethernet first, then wifi
        command: ["bash", "-c",
            "eth=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ':ethernet:connected' | head -1 | cut -d: -f1); " +
            "if [ -n \"$eth\" ]; then echo \"ETH\"; exit; fi; " +
            "wifi=$(nmcli -t -f DEVICE,SIGNAL,ACTIVE device wifi list 2>/dev/null | grep ':yes' | head -1); " +
            "if [ -n \"$wifi\" ]; then echo \"WIFI:$(echo $wifi | cut -d: -f2)\"; fi"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("WIFI:")) {
                    root.netType   = "WIFI"
                    root.netSignal = parseInt(line.slice(5)) || 0
                } else if (line.trim() === "ETH") {
                    root.netType   = "ETH"
                    root.netSignal = 0
                } else {
                    root.netType   = "NO CONNECTION"
                    root.netSignal = 0
                }
            }
        }
    }

    // Network throughput — sum all non-loopback interfaces from /proc/net/dev
    Process {
        id: netSpeedProc
        command: ["bash", "-c",
            "awk 'NR>2 && !/lo:/ {gsub(/:/, \" \"); rx+=$2; tx+=$10} END {print rx, tx}' /proc/net/dev"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/)
                if (parts.length < 2) return
                const rx  = parseFloat(parts[0])
                const tx  = parseFloat(parts[1])
                const now = Date.now()
                if (root._netPrev) {
                    const dt = (now - root._netPrev.time) / 1000
                    if (dt > 0) {
                        root.netRxRate = (rx - root._netPrev.rx) / dt
                        root.netTxRate = (tx - root._netPrev.tx) / dt
                        root.netHistory = root.netHistory
                            .concat([{ rx: root.netRxRate, tx: root.netTxRate }])
                            .slice(-20)
                    }
                }
                root._netPrev = { rx: rx, tx: tx, time: now }
            }
        }
    }

    // CPU temperature — read from coretemp hwmon, fallback to thermal_zone0
    property real cpuTemp: 0

    Process {
        id: cpuTempProc
        command: ["bash", "-c",
            "f=$(ls /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input 2>/dev/null | head -1); " +
            "[ -n \"$f\" ] && cat \"$f\" || cat /sys/class/thermal/thermal_zone0/temp"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                const millideg = parseInt(line)
                if (!isNaN(millideg)) root.cpuTemp = Math.round(millideg / 1000)
            }
        }
    }

    // Top-5 processes by CPU
    property var cpuTopProcs: []

    Process {
        id: topProcsProc
        command: ["bash", "-c", "ps -eo comm,%cpu --sort=-%cpu --no-headers | head -5"]
        running: false
        property var _lines: []
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/)
                if (parts.length < 2) return
                const raw  = parts[0]
                const name = (raw.length > 11 ? raw.substring(0, 10) + "…" : raw).toUpperCase()
                const pct  = parseFloat(parts[1]) || 0
                topProcsProc._lines.push({ name: name, pct: pct })
            }
        }
        onRunningChanged: {
            if (running) topProcsProc._lines = []
            else root.cpuTopProcs = topProcsProc._lines.slice()
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
            cpuProc.running     = true
            ramProc.running     = true
            cpuTempProc.running = true
            batIntProc.running  = true
            batExtProc.running = true
            netProc.running      = true
            netSpeedProc.running = true
            tsProc.running       = true
            topProcsProc.running = true
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

    function barStrR(pct) {
        const filled = Math.round(pct / 100 * 8)
        return "░".repeat(8 - filled) + "█".repeat(filled)
    }

    function tempColor(temp) {
        if (temp >= 80) return root.colRed
        if (temp >= 60) return root.colBlue
        return root.colGreen
    }

    function netRateStr(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + " MB/s"
        if (bps >= 1024)    return Math.round(bps / 1024)     + " KB/s"
        return Math.round(bps) + " B/s"
    }

    function batColor(pct, charging) {
        if (charging)  return root.colBlue
        if (pct <= 15) return root.colRed
        return root.colGreen
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
            id: bottomLeft
            anchors {
                bottom: parent.bottom
                left:   parent.left
                margins: root.margin
            }
            spacing: 4

            // Top-5 CPU processes
            Repeater {
                model: root.cpuTopProcs
                Row {
                    spacing: 6
                    Text {
                        text: modelData.name
                        font.family:    root.fontCondensed
                        font.pixelSize: 24
                        color: root.colWhite
                        width: 100
                        elide: Text.ElideRight
                    }
                    Text {
                        text: root.barStr(modelData.pct)
                        font.family:    root.fontNormal
                        font.pixelSize: 24
                        color: root.colBlue
                    }
                    Text {
                        text: " " + Math.round(modelData.pct) + "%"
                        font.family:    root.fontNormal
                        font.pixelSize: 24
                        color: root.colWhite
                    }
                }
            }

            // Spacer between process list and system stats
            Item { width: 1; height: 8 }

            // CPU row
            Row {
                spacing: 6
                Text {
                    text: "CPU"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 100
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
                    width: 100
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

            // TMP row
            Row {
                spacing: 6
                Text {
                    text: "TMP"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 100
                }
                Text {
                    text: root.barStr(root.cpuTemp)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.tempColor(root.cpuTemp)
                }
                Text {
                    text: " " + root.cpuTemp + "°C"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                }
            }

            // SWP row (hidden when no swap)
            Row {
                spacing: 6
                visible: root.swapUsage > 0
                Text {
                    text: "SWP"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    color: root.colWhite
                    width: 100
                }
                Text {
                    text: root.barStr(root.swapUsage)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colRed
                }
                Text {
                    text: " " + root.swapUsage + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                }
            }
        }

        // Above bottom-right panel: net traffic history graph
        // Width tracks the right panel; bars grow upward from the baseline
        Canvas {
            id: netGraph
            height: 48
            width:  bottomRight.width
            anchors {
                right:        parent.right
                bottom:       bottomRight.top
                rightMargin:  root.margin
                bottomMargin: 8
            }

            // Bar geometry
            readonly property int barW:   10
            readonly property int barGap: 1  // gap between TX and RX within a pair
            readonly property int pairW:  barW * 2 + barGap + 2  // +2 inter-pair gap

            Connections {
                target: root
                function onNetHistoryChanged() { netGraph.requestPaint() }
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                const hist = root.netHistory
                if (hist.length === 0) return

                // Dynamic max — peak of all values in the window, floored at 1 B/s
                let peak = 1
                for (let i = 0; i < hist.length; i++) {
                    if (hist[i].rx > peak) peak = hist[i].rx
                    if (hist[i].tx > peak) peak = hist[i].tx
                }

                // Draw right-to-left so newest sample is on the right
                const count = Math.min(hist.length, Math.floor(width / pairW))
                for (let i = 0; i < count; i++) {
                    const sample = hist[hist.length - 1 - i]
                    const x = width - (i + 1) * pairW

                    const txH = Math.max(1, Math.round(sample.tx / peak * height))
                    const rxH = Math.max(1, Math.round(sample.rx / peak * height))

                    // TX bar (blue)
                    ctx.fillStyle = root.colBlue
                    ctx.fillRect(x, height - txH, barW, txH)

                    // RX bar (green)
                    ctx.fillStyle = root.colGreen
                    ctx.fillRect(x + barW + barGap, height - rxH, barW, rxH)
                }
            }
        }


        Column {
            id: bottomRight
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
                topPadding: 10
                Text {
                    visible: root.netType === "WIFI"
                    text: root.netSignal + "%"
                    font.family:    root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    visible: root.netType === "WIFI"
                    text: root.barStrR(root.netSignal)
                    font.family:    root.fontNormal
                    font.pixelSize: 24
                    color: root.colGreen
                }
                Text {
                    text: root.netType
                    font.family:    root.fontCondensed
                    font.pixelSize: 24
                    width: 100
                    color: root.netType === "NO CONNECTION" ? root.colRed : root.colWhite
                }
            }

            // INT battery
            Row {
                anchors.right: parent.right
                spacing: 6
                Text {
                    text: root.batIntPct + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    text: root.barStrR(root.batIntPct)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.batColor(root.batIntPct, root.batIntCharging)
                }
                Text {
                    text: "INT"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    width: 100
                    color: root.colWhite
                }
            }

            // EXT battery (only shown when present)
            Row {
                anchors.right: parent.right
                spacing: 6
                visible: root.batExtPresent
                Text {
                    text: root.batExtPct + "%"
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.colWhite
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    text: root.barStrR(root.batExtPct)
                    font.family:   root.fontNormal
                    font.pixelSize: 24
                    color: root.batColor(root.batExtPct, root.batExtCharging)
                }
                Text {
                    text: "EXT"
                    font.family:   root.fontCondensed
                    font.pixelSize: 24
                    width: 100
                    color: root.colWhite
                }
            }
        }
    }
}
