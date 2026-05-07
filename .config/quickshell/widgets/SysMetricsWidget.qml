import QtQuick
import ".."
import "../Helpers.js" as Helpers

// Left-panel system metrics: LABEL  bar  VALUE
// Rows are left-aligned within the Column; spacers divide logical groups.
Column {
    id: root
    spacing: Theme.spacerSm

    required property var cpuSource
    required property var ramSource
    required property var tempSource
    required property var diskSource

    // ── CPU ────────────────────────────────────────────────────────────────
    Row {
        anchors.left: parent.left
        spacing: 6
        Text {
            text:                "CPU"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text:           Helpers.barStr(root.cpuSource.cpuUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Helpers.cpuColor(root.cpuSource.cpuUsage, Theme)
        }
        Text {
            text: root.cpuSource.cpuUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
            leftPadding:         10
        }
    }

    // Top-3 hottest cores
    Repeater {
        model: root.cpuSource.topCores
        Row {
            anchors.left: parent.left
            spacing: 6
            Text {
                text:                "C" + modelData.index
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                width:               Theme.labelWidthSm
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignLeft
            }
            Text {
                text:           Helpers.barStr(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color:          Helpers.cpuColor(modelData.pct, Theme)
            }
            Text {
                text:                modelData.pct + "%"
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignLeft
                leftPadding:         10
            }
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── RAM / SWP ──────────────────────────────────────────────────────────
    Row {
        anchors.left: parent.left
        spacing: 6
        Text {
            text:                "RAM"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text:           Helpers.barStr(root.ramSource.ramUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Theme.colCyan
        }
        Text {
            text:                root.ramSource.ramUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
            leftPadding:         10
        }
    }

    Row {
        anchors.left: parent.left
        spacing: 6
        visible: root.ramSource.swapUsage > 0
        Text {
            text:                "SWP"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text:           Helpers.barStr(root.ramSource.swapUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Theme.colRed
        }
        Text {
            text:                root.ramSource.swapUsage + "%"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
            leftPadding:         10
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── Temperature ────────────────────────────────────────────────────────
    Row {
        anchors.left: parent.left
        spacing: 6
        Text {
            text:                "TMP"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            width:               Theme.labelWidthSm
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text:           Helpers.barStr(root.tempSource.cpuTemp)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color:          Helpers.tempColor(root.tempSource.cpuTemp, Theme)
        }
        Text {
            text:                root.tempSource.cpuTemp + "°C"
            font.family:         Theme.fontNormal
            font.pixelSize:      Theme.fontSizeMd
            color:               Theme.colWhite
            horizontalAlignment: Text.AlignLeft
            leftPadding:         10
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // ── Disk ───────────────────────────────────────────────────────────────
    Repeater {
        model: root.diskSource.diskMounts
        Row {
            anchors.left: parent.left
            spacing: 6
            Text {
                text:                modelData.mount
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                width:               Theme.labelWidthSm
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignLeft
                elide:               Text.ElideRight
            }
            Text {
                text:           Helpers.barStr(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color:          Helpers.diskColor(modelData.pct, Theme)
            }
            Text {
                text:                modelData.pct + "%"
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                horizontalAlignment: Text.AlignLeft
                leftPadding:         10
            }
        }
    }
}
