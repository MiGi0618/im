#ifndef MESSAGE_MODEL_H
#define MESSAGE_MODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QVector>

class MessageModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        FromRole = Qt::UserRole + 1,
        ContentRole,
        TimestampRole
    };

    explicit MessageModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addMessage(const QString &from, const QString &content, const QString &timestamp);
    void clear();

private:
    struct Message {
        QString from;
        QString content;
        QString timestamp;
    };

    QVector<Message> m_messages;
};

#endif // MESSAGE_MODEL_H
