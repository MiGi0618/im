#include "WebSocketClient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QDateTime>

WebSocketClient::WebSocketClient(QObject *parent)
    : QObject(parent)
    , m_status("disconnected")
{
    connect(&m_socket, &QWebSocket::connected, this, &WebSocketClient::onConnected);
    connect(&m_socket, &QWebSocket::disconnected, this, &WebSocketClient::onDisconnected);
    connect(&m_socket, &QWebSocket::textMessageReceived, this, &WebSocketClient::onTextMessageReceived);
    connect(&m_socket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, &WebSocketClient::onError);
}

QString WebSocketClient::status() const
{
    return m_status;
}

QString WebSocketClient::username() const
{
    return m_username;
}

MessageModel* WebSocketClient::messageModel()
{
    return &m_messageModel;
}

UserModel* WebSocketClient::userModel()
{
    return &m_userModel;
}

bool WebSocketClient::connectToServer(const QString &url, const QString &username)
{
    if (m_socket.state() != QAbstractSocket::UnconnectedState)
        m_socket.close();

    m_username = username;
    m_status = "connecting";
    emit statusChanged();
    emit usernameChanged();

    const QUrl serverUrl(url);
    if (!serverUrl.isValid()) {
        m_status = "invalid_url";
        emit statusChanged();
        emit errorOccurred("Invalid server URL");
        return false;
    }

    m_socket.open(serverUrl);
    return true;
}

void WebSocketClient::disconnectFromServer()
{
    if (m_socket.state() != QAbstractSocket::UnconnectedState)
        m_socket.close();
}

void WebSocketClient::sendMessage(const QString &to, const QString &content)
{
    if (m_socket.state() != QAbstractSocket::ConnectedState)
        return;

    QJsonObject message;
    message["type"] = "chat";
    message["to"] = to;
    message["content"] = content;

    m_socket.sendTextMessage(QJsonDocument(message).toJson(QJsonDocument::Compact));
    addLocalMessage(m_username, content);
}

void WebSocketClient::requestUserList()
{
    if (m_socket.state() != QAbstractSocket::ConnectedState)
        return;

    QJsonObject message;
    message["type"] = "list";
    m_socket.sendTextMessage(QJsonDocument(message).toJson(QJsonDocument::Compact));
}

void WebSocketClient::onConnected()
{
    m_status = "connected";
    emit statusChanged();
    emit connected();

    QJsonObject login;
    login["type"] = "login";
    login["user"] = m_username;
    m_socket.sendTextMessage(QJsonDocument(login).toJson(QJsonDocument::Compact));
}

void WebSocketClient::onDisconnected()
{
    m_status = "disconnected";
    emit statusChanged();
    emit disconnected();
}

void WebSocketClient::onError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    m_status = "error";
    emit statusChanged();
    emit errorOccurred(m_socket.errorString());
}

void WebSocketClient::onTextMessageReceived(const QString &message)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject())
        return;

    processMessage(doc.object());
}

void WebSocketClient::processMessage(const QJsonObject &data)
{
    const QString type = data.value("type").toString();

    if (type == "login_success") {
        emit loginSuccess(data.value("message").toString());
        return;
    }

    if (type == "user_list") {
        QStringList users;
        const QJsonArray arr = data.value("users").toArray();
        for (const auto &v : arr)
            users << v.toString();
        m_userModel.setUsers(users);
        return;
    }

    if (type == "chat" || (data.contains("from") && data.contains("content"))) {
        const QString from = data.value("from").toString();
        const QString content = data.value("content").toString();
        const QString ts = QDateTime::currentDateTime().toString("hh:mm:ss");
        m_messageModel.addMessage(from, content, ts);
    }
}

void WebSocketClient::addLocalMessage(const QString &from, const QString &content)
{
    const QString ts = QDateTime::currentDateTime().toString("hh:mm:ss");
    m_messageModel.addMessage(from, content, ts);
}
