#pragma once
#include <QObject>
#include <QFile>
#include "../protocol/ProtocolFactory.h"

class TransferService : public QObject
{
    Q_OBJECT

    IProtocol *m_protocol    = nullptr;
    QFile      m_outputFile;
    QString    m_currentFile;

public:
    explicit TransferService(QObject *parent = nullptr) : QObject(parent) {}
    ~TransferService() override { if (m_protocol) m_protocol->deleteLater(); }

    bool isInitialised() const { return m_protocol != nullptr; }

    void init(const QString &proto);
    void startServer(int port);
    void connectTo(const QString &host, int port);
    void sendMessage(const QString &msg);
    void sendFile(const QString &path);

signals:
    void messageReceived(const QString &msg);
    void fileReceived(const QString &path);
    void progress(int percent);
    void statusChanged(const QString &status);
};