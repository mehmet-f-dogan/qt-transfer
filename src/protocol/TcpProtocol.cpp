#include "TcpProtocol.h"
#include <QDataStream>

static const int HEADER_SIZE = static_cast<int>(sizeof(quint8) + sizeof(quint32));

void TcpProtocol::writePacket(quint8 type, const QByteArray &payload)
{
    if (!m_socket || m_socket->state() != QAbstractSocket::ConnectedState)
        return;

    QByteArray packet;
    QDataStream out(&packet, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << type << static_cast<quint32>(payload.size());
    packet.append(payload);
    m_socket->write(packet);
}

void TcpProtocol::startServer(int port)
{
    connect(&m_server, &QTcpServer::newConnection, this, [this]() {
        if (m_socket) {
            m_socket->disconnectFromHost();
            m_socket->deleteLater();
        }
        m_socket = m_server.nextPendingConnection();
        m_buffer.clear();

        connect(m_socket, &QTcpSocket::readyRead, this, [this]() {
            m_buffer.append(m_socket->readAll());
            processBuffer();
        });

        connect(m_socket, &QTcpSocket::disconnected, this, [this]() {
            m_socket->deleteLater();
            m_socket = nullptr;
            m_buffer.clear();
        });

        emit connected();
    });

    if (!m_server.listen(QHostAddress::Any, static_cast<quint16>(port)))
        emit errorOccurred("TCP server could not listen on port " + QString::number(port));
}

void TcpProtocol::connectTo(const QString &host, int port)
{
    m_socket = new QTcpSocket(this);
    m_buffer.clear();

    connect(m_socket, &QTcpSocket::connected, this, [this]() {
        emit connected();
    });

    connect(m_socket, &QTcpSocket::readyRead, this, [this]() {
        m_buffer.append(m_socket->readAll());
        processBuffer();
    });

    connect(m_socket, &QTcpSocket::errorOccurred, this,
            [this](QAbstractSocket::SocketError) {
        emit errorOccurred(m_socket->errorString());
    });

    m_socket->connectToHost(host, static_cast<quint16>(port));
}

void TcpProtocol::processBuffer()
{
    while (true) {
        if (m_buffer.size() < HEADER_SIZE)
            return;

        QDataStream in(m_buffer);
        in.setByteOrder(QDataStream::BigEndian);
        quint8  type;
        quint32 payloadSize;
        in >> type >> payloadSize;

        if (m_buffer.size() < HEADER_SIZE + static_cast<int>(payloadSize))
            return;

        QByteArray payload = m_buffer.mid(HEADER_SIZE, static_cast<int>(payloadSize));
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

        m_buffer.remove(0, HEADER_SIZE + static_cast<int>(payloadSize));
    }
}

void TcpProtocol::sendMessage(const QString &msg)
{
    QByteArray payload;
    QDataStream out(&payload, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << msg;
    writePacket(TextMessage, payload);
}

void TcpProtocol::sendFileStart(const QString &filename, qint64 size)
{
    QByteArray payload;
    QDataStream out(&payload, QIODevice::WriteOnly);
    out.setByteOrder(QDataStream::BigEndian);
    out << filename << size;
    writePacket(FileStart, payload);
}

void TcpProtocol::sendFileChunk(const QByteArray &chunk)
{
    writePacket(FileChunk, chunk);
}

void TcpProtocol::sendFileEnd()
{
    writePacket(FileEnd, QByteArray());
}