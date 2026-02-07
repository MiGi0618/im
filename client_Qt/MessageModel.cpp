#include "MessageModel.h"

MessageModel::MessageModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int MessageModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_messages.size();
}

QVariant MessageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_messages.size())
        return {};

    const Message &msg = m_messages.at(index.row());
    switch (role) {
    case FromRole:
        return msg.from;
    case ContentRole:
        return msg.content;
    case TimestampRole:
        return msg.timestamp;
    default:
        return {};
    }
}

QHash<int, QByteArray> MessageModel::roleNames() const
{
    return {
        { FromRole, "from" },
        { ContentRole, "content" },
        { TimestampRole, "timestamp" }
    };
}

void MessageModel::addMessage(const QString &from, const QString &content, const QString &timestamp)
{
    beginInsertRows(QModelIndex(), m_messages.size(), m_messages.size());
    m_messages.push_back({from, content, timestamp});
    endInsertRows();
}

void MessageModel::clear()
{
    beginResetModel();
    m_messages.clear();
    endResetModel();
}
