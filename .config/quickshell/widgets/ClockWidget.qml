import QtQuick
import ".."

Column {
    spacing: Theme.spacerSm

    anchors {
        top:    parent.top
        right:  parent.right
        margins: Theme.margin
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockTime.text = Qt.formatTime(new Date(), "HH:mm")
            clockDate.text = Qt.formatDate(new Date(), "ddd · d MMM")
        }
    }

    Text {
        id: clockTime
        anchors.right: parent.right
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeLg
        color: Theme.colWhite
    }

    Text {
        id: clockDate
        anchors.right: parent.right
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeMd
        color: Theme.colWhite
    }
}
