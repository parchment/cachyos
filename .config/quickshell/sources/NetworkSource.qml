import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string netType:   "NO CONNECTION"
    property int    netSignal: 0
    property real   netRxRate: 0
    property real   netTxRate: 0
    property real   txEma:     0
    property real   rxEma:     0
    property var    _prev:     null

    function trigger() {
        typeProc.running  = true
        speedProc.running = true
    }

    property var typeProc: Process {
        id: typeProc
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

    property var speedProc: Process {
        id: speedProc
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
                if (root._prev) {
                    const dt = (now - root._prev.time) / 1000
                    if (dt > 0) {
                        root.netRxRate = (rx - root._prev.rx) / dt
                        root.netTxRate = (tx - root._prev.tx) / dt
                        const α = 0.02
                        root.txEma = root.txEma === 0 ? root.netTxRate : α * root.netTxRate + (1 - α) * root.txEma
                        root.rxEma = root.rxEma === 0 ? root.netRxRate : α * root.netRxRate + (1 - α) * root.rxEma
                    }
                }
                root._prev = { rx: rx, tx: tx, time: now }
            }
        }
    }
}
