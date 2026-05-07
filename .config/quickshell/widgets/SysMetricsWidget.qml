import QtQuick
import ".."
import "../Helpers.js" as Helpers

// Right-panel system metrics: VALUE  bar  LABEL
// Rows are right-aligned within the Column; spacers divide logical groups.
Column {
    id: root
    spacing: Theme.spacerSm

    required property var cpuSource
    required property var ramSource
    required property var tempSource
    required property var diskSource

    // ── CPU ────────────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        spacing: 6
        Text {
            text: root.cpuSource.cpuUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding:        10
        }
        Text {
            text:           Helpers.barStrR(root.cpuSource.cpuUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Helpers.cpuColor(root.cpuSource.cpuUsage, Theme)
        }
        Text {
            text:                "CPU"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    // Top-3 hottest cores
    Repeater {
        model: root.cpuSource.topCores
        Row {
            anchors.right: parent.right
            spacing: 6
            Text {
                text:                modelData.pct + "%"
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignRight
                rightPadding:        10
            }
            Text {
                text:           Helpers.barStrR(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color:          Helpers.cpuColor(modelData.pct, Theme)
            }
            Text {
                text:                "C" + modelData.index
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                width:               Theme.labelWidthSm
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── RAM / SWP ──────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        spacing: 6
        Text {
            text:                root.ramSource.ramUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding:        10
        }
        Text {
            text:           Helpers.barStrR(root.ramSource.ramUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Theme.colCyan
        }
        Text {
            text:                "RAM"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    Row {
        anchors.right: parent.right
        spacing: 6
        visible: root.ramSource.swapUsage > 0
        Text {
            text:                root.ramSource.swapUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding:        10
        }
        Text {
            text:           Helpers.barStrR(root.ramSource.swapUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Theme.colRed
        }
        Text {
            text:                "SWP"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── Temperature ────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        spacing: 6
        Text {
            text:                root.tempSource.cpuTemp + "°C"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
            rightPadding:        10
        }
        Text {
            text:           Helpers.barStrR(root.tempSource.cpuTemp)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Helpers.tempColor(root.tempSource.cpuTemp, Theme)
        }
        Text {
            text:                "TMP"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignRight
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── Disk ───────────────────────────────────────────────────────────────
    Repeater {
        model: root.diskSource.diskMounts
        Row {
            anchors.right: parent.right
            spacing: 6
            Text {
                text:                modelData.pct + "%"
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignRight
                rightPadding:        10
            }
            Text {
                text:           Helpers.barStrR(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color:          Helpers.diskColor(modelData.pct, Theme)
            }
            Text {
                text:                modelData.mount
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                width:               Theme.labelWidthSm
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignRight
                elide:               Text.ElideLeft
            }
        }
    }
}
