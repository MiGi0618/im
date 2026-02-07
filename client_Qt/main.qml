import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import IMClient 1.0

ApplicationWindow {
    id: window
    width: 360
    height: 640
    visible: true
    title: "IM Client MVP"

    Material.theme: Material.Light
    Material.accent: Material.Blue

    property int spacingUnit: Math.max(8, Math.round(Math.min(width, height) / 60))
    property int pagePadding: Math.max(12, spacingUnit * 2)

    WebSocketClient {
        id: client
        onLoginSuccess: {
            stack.currentIndex = 1
            client.requestUserList()
        }
        onErrorOccurred: {
            errorText.text = error
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0

        // Login page
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Pane {
                anchors.centerIn: parent
                width: Math.min(parent.width - pagePadding * 2, 420)
                padding: pagePadding

                ColumnLayout {
                    anchors.fill: parent
                    spacing: spacingUnit

                    Text {
                        text: "IM Client"
                        font.pixelSize: Math.max(20, spacingUnit * 2)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        id: serverField
                        placeholderText: "Server URL (e.g. ws://139.199.89.126:8765)"
                        text: "ws://139.199.89.126:8765"
                        Layout.fillWidth: true
                    }

                    TextField {
                        id: usernameField
                        placeholderText: "Username"
                        Layout.fillWidth: true
                        maximumLength: 20
                        onAccepted: connectButton.clicked()
                    }

                    Button {
                        id: connectButton
                        text: "Connect"
                        Layout.fillWidth: true
                        enabled: serverField.text.length > 0 && usernameField.text.length > 0
                        onClicked: {
                            errorText.text = ""
                            client.connectToServer(serverField.text, usernameField.text)
                        }
                    }

                    Text {
                        id: errorText
                        text: ""
                        color: "red"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Chat page
        Item {
            id: chatPage
            Layout.fillWidth: true
            Layout.fillHeight: true

            Timer {
                id: userListTimer
                interval: 3000
                repeat: true
                running: stack.currentIndex === 1 && client.status === "connected"
                onTriggered: client.requestUserList()
            }

            ListModel {
                id: recipientModel
            }

            function rebuildRecipients() {
                var selected = recipientBox.currentText
                recipientModel.clear()
                var users = client.userModel.users
                if (!users || users.length === 0)
                    return
                var name = client.username
                var selectedIndex = -1
                for (var i = 0; i < users.length; ++i) {
                    if (users[i] !== name) {
                        recipientModel.append({ "name": users[i] })
                        if (users[i] === selected)
                            selectedIndex = recipientModel.count - 1
                    }
                }
                if (selectedIndex >= 0)
                    recipientBox.currentIndex = selectedIndex
            }

            Connections {
                target: client.userModel
                function onUsersChanged() { chatPage.rebuildRecipients() }
            }

            Connections {
                target: client
                function onUsernameChanged() { chatPage.rebuildRecipients() }
            }

            Component.onCompleted: chatPage.rebuildRecipients()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: pagePadding
                spacing: spacingUnit

                RowLayout {
                    Layout.fillWidth: true
                    spacing: spacingUnit

                    Text {
                        text: "Status: " + client.status
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Disconnect"
                        onClicked: {
                            client.disconnectFromServer()
                            stack.currentIndex = 0
                        }
                    }
                }

                ListView {
                    id: messageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: client.messageModel
                    spacing: spacingUnit
                    clip: true

                    delegate: Item {
                        width: ListView.view.width
                        height: bubbleRow.implicitHeight + spacingUnit

                        property bool isSelf: model.from === client.username
                        property int bubbleMaxWidth: Math.floor(messageList.width * 0.72)
                        property int bubbleTextWidth: Math.min(bubbleMaxWidth - spacingUnit * 2,
                                                               Math.max(40, contentMetrics.width))

                        TextMetrics {
                            id: contentMetrics
                            text: model.content
                            font: contentText.font
                        }

                        RowLayout {
                            id: bubbleRow
                            anchors.fill: parent
                            spacing: spacingUnit

                            Item { Layout.fillWidth: true; visible: isSelf }

                            Rectangle {
                                id: bubble
                                color: isSelf ? "#9FE8A2" : "#FFFFFF"
                                border.color: isSelf ? "#8FD790" : "#E0E0E0"
                                border.width: 1
                                radius: 10
                                Layout.maximumWidth: bubbleMaxWidth

                                implicitWidth: bubbleTextWidth + spacingUnit * 2
                                implicitHeight: contentColumn.implicitHeight + spacingUnit * 2

                                Column {
                                    id: contentColumn
                                    anchors.fill: parent
                                    anchors.margins: spacingUnit
                                    spacing: 4

                                    Text {
                                        text: model.from
                                        visible: !isSelf
                                        color: "#666"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        width: bubbleTextWidth
                                    }

                                    Text {
                                        id: contentText
                                        text: model.content
                                        wrapMode: Text.Wrap
                                        color: "#222"
                                        width: bubbleTextWidth
                                    }

                                    Text {
                                        text: model.timestamp
                                        font.pixelSize: 10
                                        color: "#999"
                                        width: bubbleTextWidth
                                        horizontalAlignment: isSelf ? Text.AlignRight : Text.AlignLeft
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true; visible: !isSelf }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: spacingUnit

                    ComboBox {
                        id: recipientBox
                        Layout.fillWidth: true
                        model: recipientModel
                        textRole: "name"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: spacingUnit

                        TextField {
                            id: messageField
                            Layout.fillWidth: true
                            placeholderText: "Type message"
                            onAccepted: sendButton.clicked()
                        }

                        Button {
                            id: sendButton
                            text: "Send"
                            enabled: messageField.text.length > 0
                            onClicked: {
                                if (recipientBox.currentText.length > 0) {
                                    client.sendMessage(recipientBox.currentText, messageField.text)
                                    messageField.clear()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
