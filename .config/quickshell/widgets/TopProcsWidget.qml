import QtQuick
import ".."
import "../Helpers.js" as Helpers

// Top processes — CPU+RAM split bars, one entry per process.
Column {
    id: root
    spacing: Theme.spacerSm

    required property var topProcsSource

    TextMetrics {
        id: cpuMetrics
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeSm
        text: "100% "
    }
    TextMetrics {
        id: ramMetrics
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeSm
        text: "100.0%  "
    }

    Repeater {
        model: root.topProcsSource.topProcs
        Column {
            spacing: 2
            Text {
                text:                modelData.name
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                width:               Theme.labelWidthMd
                anchors.right:       parent.right
                elide:               Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
            Row {
                anchors.right: parent.right
                spacing: 0
                Text {
                    text:               Math.round(modelData.cpu) + "% "
                    font.family:        Theme.fontNormal
                    font.pixelSize:     Theme.fontSizeSm
                    color:              Theme.colBlue
                    width:              cpuMetrics.width
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    text:               modelData.ram.toFixed(1) + "%  "
                    font.family:        Theme.fontNormal
                    font.pixelSize:     Theme.fontSizeSm
                    color:              Theme.colCyan
                    width:              ramMetrics.width
                    horizontalAlignment: Text.AlignRight
                }
                // CPU: scale ceil 50% → full bar; RAM: scale ceil 5% → full bar
                SplitBarWidget {
                    barWidth:  Theme.barWidthSplit
                    leftFrac:  Math.min(1, modelData.cpu / 50)
                    rightFrac: Math.min(1, modelData.ram / 5)
                }
            }
        }
    }
}
