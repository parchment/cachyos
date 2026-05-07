import QtQuick
import ".."
import "../Helpers.js" as Helpers

Column {
    id: root
    spacing: Theme.spacerSm

    required property var netSource
    required property var batSource

    // Network connection type + optional WiFi signal bar
    Row {
        anchors.right: parent.right
        spacing: 6
        Text {
            visible: root.netSource.netType === "WIFI"
            text: root.netSource.netSignal + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding: 10
        }
        Text {
            visible: root.netSource.netType === "WIFI"
            text: Helpers.barStrR(root.netSource.netSignal)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colGreen
        }
        Text {
            text: root.netSource.netType
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            width: Theme.labelWidthSm
            color: root.netSource.netType === "NO CONNECTION" ? Theme.colRed : Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // INT battery
    Row {
        anchors.right: parent.right
        spacing: 6
        Text {
            text: root.batSource.batIntPct + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding: 10
        }
        Text {
            text: Helpers.barStrR(root.batSource.batIntPct)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Helpers.batColor(root.batSource.batIntPct, root.batSource.batIntCharging, Theme)
        }
        Text {
            text: "INT"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            width: Theme.labelWidthSm
            color: Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    // EXT battery (only shown when present)
    Row {
        anchors.right: parent.right
        spacing: 6
        visible: root.batSource.batExtPresent
        Text {
            text: root.batSource.batExtPct + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding: 10
        }
        Text {
            text: Helpers.barStrR(root.batSource.batExtPct)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Helpers.batColor(root.batSource.batExtPct, root.batSource.batExtCharging, Theme)
        }
        Text {
            text: "EXT"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            width: Theme.labelWidthSm
            color: Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }
}
