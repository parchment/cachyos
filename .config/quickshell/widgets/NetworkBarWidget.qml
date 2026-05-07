import QtQuick
import ".."
import "../Helpers.js" as Helpers

Column {
    id: root
    spacing: 2

    required property var netSource

    // Bar row: ████░░ ░░░███  (flush, no arrows — they live on the label row)
    SplitBarWidget {
        id: bar
        anchors.right: parent.right
        barWidth:  Theme.barWidthSplit
        leftFrac:  root.netSource.txEma > 0 ? Math.min(1, root.netSource.netTxRate / (root.netSource.txEma * 3.0)) : 0
        rightFrac: root.netSource.rxEma > 0 ? Math.min(1, root.netSource.netRxRate / (root.netSource.rxEma * 3.0)) : 0
        leftColor:  Theme.colBlue
        rightColor: Theme.colGreen
    }

    // Rate label row: RX ↓ pinned left, TX ↑ pinned right — same width as bar
    Item {
        anchors.right: parent.right
        width: bar.width
        height: 24
        Text {
            anchors.left: parent.left
            text: Helpers.netRateStr(root.netSource.netRxRate) + " ↓"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colGreen
        }
        Text {
            anchors.right: parent.right
            text: "↑ " + Helpers.netRateStr(root.netSource.netTxRate)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colBlue
        }
    }
}
