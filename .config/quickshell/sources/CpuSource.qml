import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real cpuUsage: 0
    property var  _prev: null

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["cat", "/proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                const parts   = line.trim().split(/\s+/)
                const user    = parseInt(parts[1])
                const nice    = parseInt(parts[2])
                const system  = parseInt(parts[3])
                const idle    = parseInt(parts[4])
                const iowait  = parseInt(parts[5])
                const irq     = parseInt(parts[6])
                const softirq = parseInt(parts[7])
                const total   = user + nice + system + idle + iowait + irq + softirq
                const used    = total - idle - iowait
                if (root._prev) {
                    const dt = total - root._prev.total
                    const du = used  - root._prev.used
                    root.cpuUsage = dt > 0 ? Math.round(du / dt * 100) : 0
                }
                root._prev = { total: total, used: used }
            }
        }
    }
}
