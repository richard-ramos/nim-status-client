import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"
import "../../shared"

GridView {
    id: root
    visible: count > 0
    anchors.fill: parent
    cellWidth: 88
    cellHeight: 88
    model: stickerList
    focus: true
    clip: true
    signal stickerClicked(string hash, int packId)
    delegate: Item {
        width: stickerGrid.cellWidth
        height: stickerGrid.cellHeight
        Column {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            Image {
                width: 80
                height: 80
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                source: "https://ipfs.infura.io/ipfs/" + url
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        root.stickerClicked(hash, packId)
                    }
                }
            }
        }
    }
}
