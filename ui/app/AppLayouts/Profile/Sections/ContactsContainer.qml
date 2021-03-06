import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../../Chat/components"
import "./Contacts"

Item {
    id: contactsContainer
    Layout.fillHeight: true
    property alias searchStr: searchBox.text
    property bool isPending: false

    SearchBox {
        id: searchBox
        anchors.top: parent.top
        anchors.topMargin: 32
        fontPixelSize: 15
    }

    Item {
        id: addNewContact
        anchors.top: searchBox.bottom
        anchors.topMargin: Style.current.bigPadding
        width: addButton.width + usernameText.width + Style.current.padding
        height: addButton.height


        StatusRoundButton {
            id: addButton
            icon.name: "plusSign"
            size: "medium"
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: usernameText
            //% "Add new contact"
            text: qsTrId("add-new-contact")
            color: Style.current.blue
            anchors.left: addButton.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: addButton.verticalCenter
            font.pixelSize: 15
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                addContactModal.open()
            }
        }
    }

    Item {
        id: blockedContactsButton
        anchors.top: addNewContact.bottom
        anchors.topMargin: Style.current.bigPadding
        width: blockButton.width + blockButtonLabel.width + Style.current.padding
        height: addButton.height

        StatusRoundButton {
            id: blockButton
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "block-icon"
            icon.color: Style.current.lightBlue
            width: 40
            height: 40
        }

        StyledText {
            id: blockButtonLabel
            //% "Blocked contacts"
            text: qsTrId("blocked-contacts")
            color: Style.current.blue
            anchors.left: blockButton.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: blockButton.verticalCenter
            font.pixelSize: 15
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                blockedContactsModal.open()
            }
        }
    }

    ModalPopup {
        id: blockedContactsModal
        //% "Blocked contacts"
        title: qsTrId("blocked-contacts")

        ContactList {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            contacts: profileModel.blockedContacts
            selectable: false
        }
    }

    Connections {
        target: profileModel
        onContactToAddChanged: {
            contactsContainer.isPending = false
        }
    }

    Component {
        id: loadingIndicator
        LoadingImage {
            width: 12
            height: 12
        }
    }

    ModalPopup {
        id: addContactModal
        //% "Add contact"
        title: qsTrId("add-contact")

        property var lookupContact: Backpressure.debounce(addContactSearchInput, 400, function (value) {
            profileModel.lookupContact(value)
        })

        onOpened: {
            addContactSearchInput.text = ""
        }

        Input {
            id: addContactSearchInput
            //% "Enter ENS username or chat key"
            placeholderText: qsTrId("enter-contact-code")
            customHeight: 44
            fontPixelSize: 15
            onEditingFinished: {
                contactsContainer.isPending = true
                profileModel.lookupContact(inputValue)
                contactsContainer.isPending = false
            }
            onTextChanged: {
                if (addContactSearchInput.text !== "") {
                  contactsContainer.isPending = true
                }
            }
            Keys.onReleased: {
                Qt.callLater(addContactModal.lookupContact, addContactSearchInput.text)
            }
        }

        Loader {
            sourceComponent: loadingIndicator
            anchors.top: addContactSearchInput.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            active: contactsContainer.isPending
        }

        Item {
          id: contactToAddInfo
          anchors.top: addContactSearchInput.bottom
          anchors.topMargin: Style.current.padding
          anchors.horizontalCenter: parent.horizontalCenter
          height: contactUsername.height
          width: contactUsername.width + contactPubKey.width
          visible: !contactsContainer.isPending && !!addContactSearchInput.text


          StyledText {
              anchors.horizontalCenter: parent.horizontalCenter
              font.pixelSize: 12
              color: Style.current.darkGrey
              //% "User not found"
              text: qsTrId("user-not-found")
              visible: !contactsContainer.isPending && !!!profileModel.contactToAddUsername
          }

          StyledText {
              id: contactUsername
              text: profileModel.contactToAddUsername + " • "
              font.pixelSize: 12
              color: Style.current.darkGrey
              visible: !!profileModel.contactToAddPubKey
          }

          StyledText {
              id: contactPubKey
              text: profileModel.contactToAddPubKey
              anchors.left: contactUsername.right
              width: 100
              font.pixelSize: 12
              elide: Text.ElideMiddle
              color: Style.current.darkGrey
              visible: !!profileModel.contactToAddPubKey
          }

        }
        footer: StyledButton {
            anchors.right: parent.right
            anchors.leftMargin: Style.current.padding
            //% "Add contact"
            label: qsTrId("add-contact")
            disabled: !contactToAddInfo.visible
            anchors.bottom: parent.bottom
            onClicked: {
                profileModel.addContact(profileModel.contactToAddPubKey);
                addContactModal.close()
            }
        }
    }

    ContactList {
        id: contactListView
        anchors.top: blockedContactsButton.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.bottom: parent.bottom
        contacts: profileModel.addedContacts
        selectable: false
        searchString: searchBox.text
    }

    Item {
        id: element
        visible: profileModel.contactList.rowCount() === 0
        anchors.fill: parent

        StyledText {
            id: noFriendsText
            //% "You don’t have any contacts yet"
            text: qsTrId("you-don-t-have-any-contacts-yet")
            anchors.verticalCenterOffset: -Style.current.bigPadding
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
            color: Style.current.darkGrey
        }

        StyledButton {
            anchors.horizontalCenter: noFriendsText.horizontalCenter
            anchors.top: noFriendsText.bottom
            anchors.topMargin: Style.current.bigPadding
            //% "Invite friends"
            label: qsTrId("invite-friends")
            onClicked: function () {
                inviteFriendsPopup.open()
            }
        }

        InviteFriendsPopup {
            id: inviteFriendsPopup
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.6600000262260437;height:480;width:600}
}
##^##*/
