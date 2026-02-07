#ifndef USER_MODEL_H
#define USER_MODEL_H

#include <QAbstractListModel>
#include <QStringList>

class UserModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList users READ users NOTIFY usersChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1
    };

    explicit UserModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setUsers(const QStringList &users);
    QStringList users() const;

signals:
    void usersChanged();

private:
    QStringList m_users;
};

#endif // USER_MODEL_H
