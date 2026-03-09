#pragma once
#include "IProtocol.h"
#include <QTcpServer>
#include <QTcpSocket>

class TcpProtocol : public IProtocol
{
    Q_OBJECT

    QTcpServer  m_server;
    QTcpSocket *m_socket = nullptr;
    QByteArray  m_buffer;

    void processBuffer();
    void writePacket(quint8 type, const QByteArray &payload);

public:
    void startServer(int port)                        override;
    void connectTo(const QString &host, int port)     override;

    void sendMessage(const QString &msg)              override;
    void sendFileStart(const QString &filename,
                       qint64 size)                   override;
    void sendFileChunk(const QByteArray &chunk)       override;
    void sendFileEnd()                                override;
};