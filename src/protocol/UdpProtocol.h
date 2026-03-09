#pragma once
#include "IProtocol.h"
#include <QUdpSocket>
#include <QHostAddress>

class UdpProtocol : public IProtocol
{
    Q_OBJECT

    QUdpSocket   m_socket;
    QHostAddress m_remote;       
    quint16      m_sendPort  = 0;
    bool         m_serverMode = false;

    void writePacket(quint8 type, const QByteArray &payload);

private slots:
    void onReadyRead();

public:
    void startServer(int port)                        override;
    void connectTo(const QString &host, int port)     override;

    void sendMessage(const QString &msg)              override;
    void sendFileStart(const QString &filename,
                       qint64 size)                   override;
    void sendFileChunk(const QByteArray &chunk)       override;
    void sendFileEnd()                                override;

    int maxChunkSize() const                          override { return 8192; }
};