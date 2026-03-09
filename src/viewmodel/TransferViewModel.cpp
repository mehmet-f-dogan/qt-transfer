#include "TransferViewModel.h"

TransferViewModel::TransferViewModel(TransferService *service, QObject *parent)
    : QObject(parent), m_service(service)
{
    connect(m_service, &TransferService::progress,
            this, &TransferViewModel::onProgress);
    connect(m_service, &TransferService::statusChanged,
            this, &TransferViewModel::onStatusChanged);
    connect(m_service, &TransferService::messageReceived,
            this, &TransferViewModel::onMessageReceived);
    connect(m_service, &TransferService::fileReceived,
            this, &TransferViewModel::onFileReceived);
}

void TransferViewModel::init(const QString &proto)
{
    if (m_service) m_service->init(proto);
}

void TransferViewModel::startServer(int port)
{
    if (m_service) m_service->startServer(port);
}

void TransferViewModel::connectTo(const QString &host, int port)
{
    if (m_service) m_service->connectTo(host, port);
}

void TransferViewModel::sendMessage(const QString &msg)
{
    if (m_service) m_service->sendMessage(msg);
}

void TransferViewModel::sendFile(const QString &path)
{
    if (m_service) m_service->sendFile(path);
}

void TransferViewModel::onProgress(int value)
{
    m_progress = value;
    emit progressChanged(m_progress);
}

void TransferViewModel::onStatusChanged(const QString &status)
{
    m_status = status;
    emit statusChanged(m_status);
}

void TransferViewModel::onMessageReceived(const QString &msg)
{
    emit messageReceived(msg);
}

void TransferViewModel::onFileReceived(const QString &path)
{
    emit fileReceived(path);
}