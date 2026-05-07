import QtQuick
import ".."
import "../Helpers.js" as Helpers

// Split bar: left side fills right (e.g. CPU), right side fills left (e.g. RAM).
// Pass fractions 0.0..1.0; callers handle domain-specific scaling.
Row {
    id: root
    spacing: 0

    required property real leftFrac   // 0.0..1.0
    required property real rightFrac  // 0.0..1.0

    property int   barWidth:   6
    property color leftColor:  Theme.colBlue
    property color rightColor: Theme.colCyan

    Text {
        text: Helpers.splitLeftStr(root.leftFrac, root.barWidth)
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeMd
        color: root.leftColor
    }
    Text {
        text: " "
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeMd
    }
    Text {
        text: Helpers.splitRightStr(root.rightFrac, root.barWidth)
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeMd
        color: root.rightColor
    }
}
