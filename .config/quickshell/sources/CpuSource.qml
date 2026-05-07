import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real cpuUsage: 0
    property var  _prev: null
    property var  _corePrev: ({})
    property var  _coreBuf:  []
    property var  topCores:  []

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["cat", "/proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                // Aggregate average
                if (line.startsWith("cpu ")) {
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
                    return
                }

                // Per-core lines (cpu0, cpu1, …)
                const coreMatch = line.match(/^cpu(\d+)\s+(.*)/)
                if (!coreMatch) return
                const idx     = parseInt(coreMatch[1])
                const parts   = coreMatch[2].trim().split(/\s+/)
                const user    = parseInt(parts[0])
                const nice    = parseInt(parts[1])
                const system  = parseInt(parts[2])
                const idle    = parseInt(parts[3])
                const iowait  = parseInt(parts[4])
                const irq     = parseInt(parts[5])
                const softirq = parseInt(parts[6])
                const total   = user + nice + system + idle + iowait + irq + softirq
                const used    = total - idle - iowait
                root._coreBuf.push({ idx, total, used })
            }
        }
        onExited: function() {
            // Compute per-core usage deltas and find top 3
            const results = []
            for (const c of root._coreBuf) {
                const prev = root._corePrev[c.idx]
                if (prev) {
                    const dt  = c.total - prev.total
                    const du  = c.used  - prev.used
                    const pct = dt > 0 ? Math.round(du / dt * 100) : 0
                    results.push({ index: c.idx, pct: pct })
                }
                root._corePrev[c.idx] = { total: c.total, used: c.used }
            }
            root._coreBuf = []
            results.sort((a, b) => b.pct - a.pct)
            root.topCores = results.slice(0, 3)
        }
    }
}
