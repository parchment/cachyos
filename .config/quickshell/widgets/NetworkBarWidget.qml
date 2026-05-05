import QtQuick
import ".."
import "../Helpers.js" as Helpers

Column {
    id: root
    spacing: 2

    required property var netSource

    // Bar row: ↑ ████░░ ░░░███ ↓
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        Text {
            text: "↑ "
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colBlue
        }
        Text {
            text: Helpers.txBarStr(root.netSource.netTxRate, root.netSource.txEma)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colBlue
        }
        Text {
            text: " "
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
        }
        Text {
            text: Helpers.rxBarStr(root.netSource.netRxRate, root.netSource.rxEma)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colGreen
        }
        Text {
            text: " ↓"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colGreen
        }
    }

    // Rate label row: TX pinned left, RX pinned right
    Item {
        width: parent.width
        height: 24
        Text {
            anchors.left: parent.left
            text: Helpers.netRateStr(root.netSource.netTxRate)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colBlue
        }
        Text {
            anchors.right: parent.right
            text: Helpers.netRateStr(root.netSource.netRxRate)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colGreen
        }
    }
}
