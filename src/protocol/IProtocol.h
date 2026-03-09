#pragma once
#include <QObject>

enum PacketType : quint8
{
    TextMessage = 1,
    FileStart   = 2,
    FileChunk   = 3,
    FileEnd     = 4
};

class IProtocol : public QObject
{
    Q_OBJECT

public:
    virtual void startServer(int port)                       = 0;
    virtual void connectTo(const QString &host, int port)    = 0;

    virtual void sendMessage(const QString &msg)             = 0;
    virtual void sendFileStart(const QString &filename,
                               qint64 size)                  = 0;
    virtual void sendFileChunk(const QByteArray &chunk)      = 0;
    virtual void sendFileEnd()                               = 0;

    virtual int maxChunkSize() const { return 65536; }

signals:
    void messageReceived(const QString &msg);
    void fileStart(const QString &filename, qint64 size);
    void fileChunkReceived(const QByteArray &chunk);
    void fileEnd();
    void connected();
    void errorOccurred(const QString &error);
};