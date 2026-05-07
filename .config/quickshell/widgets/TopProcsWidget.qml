import QtQuick
import ".."
import "../Helpers.js" as Helpers

// Top processes — CPU+RAM split bars, one entry per process.
Column {
    id: root
    spacing: Theme.spacerSm

    required property var topProcsSource

    Repeater {
        model: root.topProcsSource.topProcs
        Column {
            spacing: 2
            Text {
                text:                modelData.name
                font.family:         Theme.fontNormal
                font.pixelSize:      Theme.fontSizeMd
                color:               Theme.colWhite
                anchors.right:       parent.right
                horizontalAlignment: Text.AlignRight
            }
            Row {
                anchors.right: parent.right
                spacing: 0
                Text {
                    text:           Math.round(modelData.cpu) + "% · " + modelData.ram.toFixed(1) + "%  "
                    font.family:    Theme.fontNormal
                    font.pixelSize: Theme.fontSizeMd
                    color:          Theme.colBlue
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
