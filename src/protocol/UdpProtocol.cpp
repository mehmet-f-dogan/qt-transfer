#include "UdpProtocol.h"
#include <QDataStream>

void UdpProtocol::writePacket(quint8 type, const QByteArray &payload)
{
    if (m_sendPort == 0)
        return;

    QByteArray packet;
    QDataStream out(&packet, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << type << static_cast<quint32>(payload.size());
    packet.append(payload);
    m_socket.writeDatagram(packet, m_remote, m_sendPort);
}

void UdpProtocol::startServer(int port)
{
    m_serverMode = true;
    m_sendPort   = 0;

    if (!m_socket.bind(QHostAddress::Any, static_cast<quint16>(port))) {
        emit errorOccurred("UDP bind failed on port " + QString::number(port));
        return;
    }

    connect(&m_socket, &QUdpSocket::readyRead, this, &UdpProtocol::onReadyRead);
}

void UdpProtocol::connectTo(const QString &host, int port)
{
    m_serverMode = false;
    m_remote     = QHostAddress(host);
    m_sendPort   = static_cast<quint16>(port);

    if (!m_socket.bind(QHostAddress::Any, 0)) {
        emit errorOccurred("UDP bind failed");
        return;
    }

    connect(&m_socket, &QUdpSocket::readyRead, this, &UdpProtocol::onReadyRead);
    emit connected();
}

void UdpProtocol::onReadyRead()
{
    while (m_socket.hasPendingDatagrams()) {
        QByteArray   data;
        QHostAddress senderAddr;
        quint16      senderPort = 0;

        data.resize(static_cast<int>(m_socket.pendingDatagramSize()));
        m_socket.readDatagram(data.data(), data.size(), &senderAddr, &senderPort);

        if (m_serverMode && m_sendPort == 0) {
            m_remote   = senderAddr;
            m_sendPort = senderPort;
            emit connected();
        }

        if (data.size() < static_cast<int>(sizeof(quint8) + sizeof(quint32)))
            continue;

        QDataStream in(data);
        in.setByteOrder(QDataStream::BigEndian);
        quint8  type;
        quint32 payloadSize;
        in >> type >> payloadSize;

        QByteArray payload = data.mid(static_cast<int>(sizeof(quint8) + sizeof(quint32)),
                                      static_cast<int>(payloadSize));
        QDataStream ps(payload);
        ps.setByteOrder(QDataStream::BigEndian);

        switch (type) {
        case TextMessage: {
            QString msg;
            ps >> msg;
            emit messageReceived(msg);
            break;
        }
        case FileStart: {
            QString name;
            qint64  sz;
            ps >> name >> sz;
            emit fileStart(name, sz);
            break;
        }
        case FileChunk:
            emit fileChunkReceived(payload);
            break;
        case FileEnd:
            emit fileEnd();
            break;
        default:
            break;
        }
    }
}

void UdpProtocol::sendMessage(const QString &msg)
{
    QByteArray payload;
    QDataStream out(&payload, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << msg;
    writePacket(TextMessage, payload);
}

void UdpProtocol::sendFileStart(const QString &filename, qint64 size)
{
    QByteArray payload;
    QDataStream out(&payload, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << filename << size;
    writePacket(FileStart, payload);
}

void UdpProtocol::sendFileChunk(const QByteArray &chunk)
{
    writePacket(FileChunk, chunk);
}

void UdpProtocol::sendFileEnd()
{
    writePacket(FileEnd, QByteArray());
}