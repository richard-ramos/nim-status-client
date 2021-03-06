import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    property string username: "Jotaro Kujo"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAhklEQVR4nOzWwQ1AQBgFYUQvelKHMtShJ9VwFyvrsExe5jvKXiYv+WPoQhhCYwiNITSG0MSEjLUPt3097r7P09L/8f4qZhFDaAyhqboIT76+TiUxixhCYwhN9b/WW6Xr1ErMIobQGEJjCI0hNIbQGEJjCI0haiRmEUNoDKExhMYQmjMAAP//B2kXcP2uDV8AAAAASUVORK5CYII="
    property string pubkey: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string ensName: "joestar.eth"
    property bool showQR: false

    id: profileHeaderContent
    height: parent.height
    Layout.fillWidth: true

    Item {
        id: profileImgNameContainer
        anchors.top: parent.top
        anchors.topMargin: 64
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin

        height: this.childrenRect.height

        Rectangle {
            id: profileImg
            width: identiconImage.width
            height: identiconImage.height
            border.width: 1
            border.color: Style.current.border
            radius: 50
            color: Style.current.background

            Image {
                id: identiconImage
                width: 44
                height: 44
                fillMode: Image.PreserveAspectFit
                source: identicon
                mipmap: true
                smooth: false
                antialiasing: true
            }
        }

        StyledText {
            id: profileName
            text: ensName !== "" ? ensName : username
            anchors.left: profileImg.right
            anchors.leftMargin: 8
            anchors.top: profileImg.top
            font.weight: Font.Medium
            font.pixelSize: 15
        }

        Address {
            id: pubkeyText
            text: ensName !== "" ? username : pubkey
            anchors.bottom: profileImg.bottom
            anchors.left: profileName.left
            width: 200
            font.pixelSize: 15
        }

        SVGImage {
            id: qrCodeImage
            source: "../../../img/qr-code-icon.svg"
            width: 18
            height: 18
            anchors.right: parent.right
            property bool hovered: false

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    parent.hovered = false
                }
                onEntered: {
                    parent.hovered = true
                }
                onClicked: {
                    showQR = !showQR
                }
            }
        }

        ColorOverlay {
            id: qrCodeOverlay
            anchors.fill: qrCodeImage
            source: qrCodeImage
            color: qrCodeImage.hovered ? Style.current.buttonForegroundColor : Style.current.textColor
        }

        Separator {
            id: lineSeparator
            anchors.top: profileImg.bottom
            anchors.topMargin: 36

        }
    }

    Item {
        anchors.fill: parent
        visible: showQR
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: profileModel.qrCode(pubkey)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 424
            width: 424
            mipmap: true
            smooth: false
        }
    }

    Column {
        visible: !showQR
        anchors.right: profileImgNameContainer.right
        anchors.left: profileImgNameContainer.left
        spacing: Style.current.bigPadding
        anchors.top: profileImgNameContainer.bottom
        anchors.topMargin: Style.current.smallPadding

        TextWithLabel {
            //% "Chat key"
            label: qsTrId("chat-key")
            text: pubkey.substring(0, 13) + "..." + pubkey.substring(pubkey.length - 13)
            textToCopy: pubkey
        }

        TextWithLabel {
            //% "Share Profile URL"
            label: qsTrId("share-profile-url")
            text: `https://join.status.im/u/${pubkey.substring(0, 5)}...${pubkey.substring(pubkey.length - 5)}`
            textToCopy: `https://join.status.im/u/${pubkey}`
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
