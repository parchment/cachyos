import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real cpuTemp: 0

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
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
}
