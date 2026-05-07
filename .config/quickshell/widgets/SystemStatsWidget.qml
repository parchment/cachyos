import QtQuick
import ".."
import "../Helpers.js" as Helpers

Column {
    id: root
    spacing: Theme.spacerSm

    required property var cpuSource
    required property var ramSource
    required property var tempSource
    required property var topProcsSource
    required property var diskSource

    // Top-5 CPU+RAM processes
    Repeater {
        model: root.topProcsSource.topProcs
        Column {
            spacing: 2
            Text {
                text: modelData.name
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Theme.colWhite
            }
            Row {
                spacing: 0
                // CPU: scale ceil 50% → full bar; RAM: scale ceil 5% → full bar
                SplitBarWidget {
                    leftFrac:  Math.min(1, modelData.cpu / 50)
                    rightFrac: Math.min(1, modelData.ram / 5)
                }
                Text {
                    text: "  " + Math.round(modelData.cpu) + "%"
                    font.family:    Theme.fontNormal
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.colBlue
                }
                Text {
                    text: " · " + modelData.ram.toFixed(1) + "%"
                    font.family:    Theme.fontNormal
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.colCyan
                }
            }
        }
    }

    Item { width: 1; height: Theme.spacerMd }

    // CPU row
    Row {
        spacing: 6
        Text {
            text: "CPU"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            width: Theme.labelWidthSm
        }
        Text {
            text: Helpers.barStr(root.cpuSource.cpuUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Helpers.cpuColor(root.cpuSource.cpuUsage, Theme)
        }
        Text {
            text: " " + root.cpuSource.cpuUsage + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
        }
    }

    // Top-3 hottest cores
    Repeater {
        model: root.cpuSource.topCores
        Row {
            spacing: 6
            Text {
                text: "C" + modelData.index
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Theme.colWhite
                width: Theme.labelWidthSm
            }
            Text {
                text: Helpers.barStr(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Helpers.cpuColor(modelData.pct, Theme)
            }
            Text {
                text: " " + modelData.pct + "%"
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Theme.colWhite
            }
        }
    }

    // RAM row
    Row {
        spacing: 6
        Text {
            text: "RAM"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            width: Theme.labelWidthSm
        }
        Text {
            text: Helpers.barStr(root.ramSource.ramUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colCyan
        }
        Text {
            text: " " + root.ramSource.ramUsage + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
        }
    }

    // TMP row
    Row {
        spacing: 6
        Text {
            text: "TMP"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            width: Theme.labelWidthSm
        }
        Text {
            text: Helpers.barStr(root.tempSource.cpuTemp)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Helpers.tempColor(root.tempSource.cpuTemp, Theme)
        }
        Text {
            text: " " + root.tempSource.cpuTemp + "°C"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
        }
    }

    // Disk rows — one per real mount >1 GB
    Repeater {
        model: root.diskSource.diskMounts
        Row {
            spacing: 6
            topPadding: Theme.spacerSm + 2
            Text {
                text: modelData.mount
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Theme.colWhite
                width: Theme.labelWidthSm
                elide: Text.ElideRight
            }
            Text {
                text: Helpers.barStr(modelData.pct)
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Helpers.diskColor(modelData.pct, Theme)
            }
            Text {
                text: " " + modelData.pct + "%  " + modelData.avail
                font.family:    Theme.fontNormal
                font.pixelSize: Theme.fontSizeMd
                color: Theme.colWhite
            }
        }
    }

    // SWP row (hidden when no swap)
    Row {
        spacing: 6
        visible: root.ramSource.swapUsage > 0
        Text {
            text: "SWP"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
            width: Theme.labelWidthSm
        }
        Text {
            text: Helpers.barStr(root.ramSource.swapUsage)
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colRed
        }
        Text {
            text: " " + root.ramSource.swapUsage + "%"
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeMd
            color: Theme.colWhite
        }
    }
}
