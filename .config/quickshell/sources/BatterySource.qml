import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int  batIntPct:      0
    property bool batIntCharging: false
    property int  batExtPct:      0
    property bool batExtCharging: false
    property bool batExtPresent:  false

    function trigger() {
        intProc.running = true
        extProc.running = true
    }

    property var intProc: Process {
        id: intProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/AC/online 2>/dev/null; " +
            "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                intProc.lineNum++
                if (intProc.lineNum === 1) root.batIntCharging = (line.trim() === "1")
                if (intProc.lineNum === 2) root.batIntPct = parseInt(line) || 0
            }
        }
        onRunningChanged: if (!running) intProc.lineNum = 0
    }

    property var extProc: Process {
        id: extProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/AC/online 2>/dev/null; " +
            "[ -d /sys/class/power_supply/BAT0 ] && echo present; " +
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"]
        running: false
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                extProc.lineNum++
                if (extProc.lineNum === 1) root.batExtCharging = (line.trim() === "1")
                if (extProc.lineNum === 2 && line.trim() === "present") root.batExtPresent = true
                if (extProc.lineNum === 3) root.batExtPct = parseInt(line) || 0
            }
        }
        onRunningChanged: if (!running) extProc.lineNum = 0
    }
}
