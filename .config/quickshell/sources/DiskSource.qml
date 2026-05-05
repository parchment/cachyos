import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var diskMounts: []   // [{ mount: string, pct: int, avail: string }, …]

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["bash", "-c",
            "df -BG -x tmpfs -x devtmpfs -x squashfs -x efivarfs 2>/dev/null | " +
            "awk 'NR>1 { sz=$2; gsub(/G/,\"\",sz); avail=$4; gsub(/G/,\"\",avail); " +
            "pct=$5; gsub(/%/,\"\",pct); if (sz+0>1 && !seen[$1]++ && $6!~/^\\/boot/) print $6, pct+0, avail+0 }'"]
        running: false
        property var _lines: []
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/)
                if (parts.length < 3) return
                proc._lines.push({
                    mount: parts[0],
                    pct:   parseInt(parts[1]) || 0,
                    avail: parts[2] + "G"
                })
            }
        }
        onRunningChanged: {
            if (running) proc._lines = []
            else root.diskMounts = proc._lines.slice()
        }
    }
}
