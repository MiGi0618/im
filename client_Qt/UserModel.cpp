#include "UserModel.h"

UserModel::UserModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int UserModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_users.size();
}

QVariant UserModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_users.size())
        return {};

    if (role == NameRole)
        return m_users.at(index.row());

    return {};
}

QHash<int, QByteArray> UserModel::roleNames() const
{
    return { { NameRole, "name" } };
}

void UserModel::setUsers(const QStringList &users)
{
    beginResetModel();
    m_users = users;
    endResetModel();
    emit usersChanged();
}

QStringList UserModel::users() const
{
    return m_users;
}
