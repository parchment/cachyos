import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var topProcs: []

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["bash", "-c", "ps -eo comm,%cpu,%mem --sort=-%cpu --no-headers | head -5"]
        running: false
        property var _lines: []
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/)
                if (parts.length < 3) return
                const raw  = parts[0]
                const name = (raw.length > 21 ? raw.substring(0, 20) + "…" : raw).toUpperCase()
                const cpu  = parseFloat(parts[1]) || 0
                const ram  = parseFloat(parts[2]) || 0
                proc._lines.push({ name: name, cpu: cpu, ram: ram })
            }
        }
        onRunningChanged: {
            if (running) proc._lines = []
            else root.topProcs = proc._lines.slice()
        }
    }
}
