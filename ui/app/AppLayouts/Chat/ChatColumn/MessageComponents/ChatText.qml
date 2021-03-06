import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"

Item {
    property bool longChatText: true
    property bool veryLongChatText: chatsModel.plainText(message).length >
                                    (appSettings.compactMode ? Constants.limitLongChatTextCompactMode : Constants.limitLongChatText)
    property bool readMore: false
    property alias textField: chatText

    id: root
    visible: contentType == Constants.messageType || isEmoji
    z: 51
    height: visible ? (showMoreLoader.active ? childrenRect.height : chatText.height) : 0

    // This function is to avoid the binding loop warning
    function setWidths() {
        if (longChatText) {
            root.width = undefined
            chatText.width = Qt.binding(function () {return root.width})
        } else {
            chatText.width = Qt.binding(function () {return chatText.implicitWidth})
            root.width = Qt.binding(function () {return chatText.width})
        }
    }

    Component.onCompleted: {
        root.setWidths()
    }

    Connections {
        enabled: !appSettings.compactMode
        target: appSettings.compactMode ? null : chatBox
        onLongChatTextChanged: {
            root.setWidths()
        }
    }

    StyledTextEdit {
        id: chatText
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        font.pixelSize: Style.current.primaryTextFontSize
        readOnly: true
        selectByMouse: true
        color: Style.current.textColor
        height: root.veryLongChatText && !root.readMore ? 200 : implicitHeight
        clip: true
        onLinkActivated: function (link) {
            if(link.startsWith("#")) {
                chatsModel.joinChat(link.substring(1), Constants.chatTypePublic);
                return;
            }

            if (link.startsWith('//')) {
                let pk = link.replace("//", "");
                openProfilePopup(chatsModel.userNameOrAlias(pk), pk, chatsModel.generateIdenticon(pk))
                return;
            }

            Qt.openUrlExternally(link)
        }
        text: {
            if(contentType === Constants.stickerType) return "";
            let msg = Utils.linkifyAndXSS(message);
            if(isEmoji) {
                return Emoji.parse(msg, Emoji.size.big);
            } else {
                return `<style type="text/css">` +
                            `p, img, a, del, code, blockquote { margin: 0; padding: 0; }` +
                            `code {` +
                                `background-color: ${Style.current.codeBackground};` +
                                `color: ${Style.current.white};` +
                                `white-space: pre;` +
                            `}` +
                            `p {` +
                                `line-height: 22px;` +
                            `}` +
                            `a {` +
                                `color: ${isCurrentUser && !appSettings.compactMode ? Style.current.white : Style.current.textColor};` +
                            `}` +
                            `a.mention {` +
                                `color: ${isCurrentUser ? Style.current.cyan : Style.current.turquoise};` +
                            `}` +
                            `del {` +
                                `text-decoration: line-through;` +
                            `}` +
                            `table.blockquote td {` +
                                `padding-left: 10px;` +
                                `color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                            `}` +
                            `table.blockquote td.quoteline {` +
                                `background-color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                                `height: 100%;` +
                                `padding-left: 0;` +
                            `}` +
                            `.emoji {` +
                                `vertical-align: bottom;` +
                            `}` +
                        `</style>` +
                        `${Emoji.parse(msg)}`
            }
        }
    }

    Loader {
        id: showMoreLoader
        active: root.veryLongChatText
        anchors.top: chatText.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: chatText.horizontalAlignment === Text.AlignLeft ? chatText.left : undefined
        anchors.right: chatText.horizontalAlignment === Text.AlignLeft ? undefined : chatText.right

        sourceComponent: Component {
            StyledText {
                text: root.readMore ?
                          qsTr("Read less") :
                          qsTr("Read more")
                color: chatText.color
                font.pixelSize: 12
                font.underline: true
                z: 100

                MouseArea {
                    z: 101
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.readMore = !root.readMore
                    }
                }
            }
        }
    }
}
