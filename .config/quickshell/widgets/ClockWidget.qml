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
            clockHH.text  = Qt.formatTime(new Date(), "HH")
            clockMM.text  = Qt.formatTime(new Date(), "mm")
            clockDay.text = Qt.formatDate(new Date(), "dddd").toUpperCase()
            clockDate.text = Qt.formatDate(new Date(), "MMM dd yyyy").toUpperCase()
        }
    }

    Row {
        anchors.right: parent.right
        spacing: 8

        Text {
            id: clockHH
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeLg
            color: Theme.colWhite
        }

        Text {
            id: clockMM
            font.family:    Theme.fontNormal
            font.pixelSize: Theme.fontSizeLg
            color: Theme.colWhite
        }
    }

    Text {
        id: clockDay
        anchors.right: parent.right
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeSm
        font.letterSpacing: 8
        color: Theme.colWhite
        opacity: 0.8
    }

    Text {
        id: clockDate
        anchors.right: parent.right
        font.family:    Theme.fontNormal
        font.pixelSize: Theme.fontSizeSm
        font.letterSpacing: 4
        color: Theme.colWhite
        opacity: 0.6
    }
}
