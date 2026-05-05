import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var cpuTopProcs: []

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
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
                proc._lines.push({ name: name, pct: pct })
            }
        }
        onRunningChanged: {
            if (running) proc._lines = []
            else root.cpuTopProcs = proc._lines.slice()
        }
    }
}
