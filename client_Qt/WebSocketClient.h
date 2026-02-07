#ifndef WEBSOCKETCLIENT_H
#define WEBSOCKETCLIENT_H

#include <QObject>
#include <QWebSocket>
#include <QJsonObject>
#include "MessageModel.h"
#include "UserModel.h"

class WebSocketClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    Q_PROPERTY(MessageModel* messageModel READ messageModel CONSTANT)
    Q_PROPERTY(UserModel* userModel READ userModel CONSTANT)

public:
    explicit WebSocketClient(QObject *parent = nullptr);

    QString status() const;
    QString username() const;
    MessageModel* messageModel();
    UserModel* userModel();

    Q_INVOKABLE bool connectToServer(const QString &url, const QString &username);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void sendMessage(const QString &to, const QString &content);
    Q_INVOKABLE void requestUserList();

signals:
    void statusChanged();
    void usernameChanged();
    void connected();
    void disconnected();
    void errorOccurred(const QString &error);
    void loginSuccess(const QString &message);

private slots:
    void onConnected();
    void onDisconnected();
    void onError(QAbstractSocket::SocketError error);
    void onTextMessageReceived(const QString &message);

private:
    void processMessage(const QJsonObject &data);
    void addLocalMessage(const QString &from, const QString &content);

    QWebSocket m_socket;
    QString m_username;
    QString m_status;
    MessageModel m_messageModel;
    UserModel m_userModel;
};

#endif // WEBSOCKETCLIENT_H
