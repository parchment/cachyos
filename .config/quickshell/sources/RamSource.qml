import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real ramUsage:  0
    property real swapUsage: 0

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["cat", "/proc/meminfo"]
        running: false
        property int memTotal:  0
        property int memAvail:  0
        property int swapTotal: 0
        stdout: SplitParser {
            onRead: function(line) {
                const m = line.match(/^(\w+):\s+(\d+)/)
                if (!m) return
                if (m[1] === "MemTotal")     proc.memTotal  = parseInt(m[2])
                if (m[1] === "MemAvailable") {
                    proc.memAvail = parseInt(m[2])
                    if (proc.memTotal > 0)
                        root.ramUsage = Math.round((1 - proc.memAvail / proc.memTotal) * 100)
                }
                if (m[1] === "SwapTotal")    proc.swapTotal = parseInt(m[2])
                if (m[1] === "SwapFree") {
                    const swapFree = parseInt(m[2])
                    root.swapUsage = proc.swapTotal > 0
                        ? Math.round((1 - swapFree / proc.swapTotal) * 100)
                        : 0
                }
            }
        }
    }
}
