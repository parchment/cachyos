import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool tailscaleUp: false

    function trigger() { proc.running = true }

    property var proc: Process {
        id: proc
        command: ["bash", "-c",
            "tailscale status --json 2>/dev/null | grep -q '\"BackendState\":\"Running\"' && echo up || echo down"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                root.tailscaleUp = (line.trim() === "up")
            }
        }
    }
}
