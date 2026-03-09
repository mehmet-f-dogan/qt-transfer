#include "TransferService.h"
#include <QDir>
#include <QFileInfo>
#include <QCoreApplication>

void TransferService::init(const QString &proto)
{
    if (m_protocol) {
        m_protocol->disconnect();
        m_protocol->deleteLater();
        m_protocol = nullptr;
    }

    m_protocol = ProtocolFactory::create(proto);
    if (!m_protocol) {
        emit statusChanged("Unknown protocol: " + proto);
        return;
    }

    connect(m_protocol, &IProtocol::connected, this, [this]() {
        emit statusChanged("Connected");
    });

    connect(m_protocol, &IProtocol::errorOccurred, this, [this](const QString &err) {
        emit statusChanged("Error: " + err);
    });

    connect(m_protocol, &IProtocol::messageReceived,
            this, &TransferService::messageReceived);

    connect(m_protocol, &IProtocol::fileStart, this, [this](const QString &name, qint64 size) {
        QDir().mkpath("received");
        // Store absolute path so Qt.openUrlExternally / ShellExecute can find it.
        m_currentFile = QDir::current().absoluteFilePath("received/" + name);
        m_outputFile.setFileName(m_currentFile);
        if (!m_outputFile.open(QIODevice::WriteOnly)) {
            emit statusChanged("Cannot write: " + m_currentFile);
            return;
        }
        emit statusChanged("Receiving: " + name +
                           "  (" + QString::number(size / 1024) + " KB)");
    });

    connect(m_protocol, &IProtocol::fileChunkReceived, this, [this](const QByteArray &chunk) {
        if (m_outputFile.isOpen())
            m_outputFile.write(chunk);
    });

    connect(m_protocol, &IProtocol::fileEnd, this, [this]() {
        if (m_outputFile.isOpen()) {
            m_outputFile.close();
            emit fileReceived(m_currentFile);
            emit statusChanged("Saved: " + m_currentFile);
        }
    });

    emit statusChanged("Initialised: " + proto);
}

void TransferService::startServer(int port)
{
    if (!m_protocol) { emit statusChanged("Not initialised"); return; }
    m_protocol->startServer(port);
    emit statusChanged("Listening on port " + QString::number(port));
}

void TransferService::connectTo(const QString &host, int port)
{
    if (!m_protocol) { emit statusChanged("Not initialised"); return; }
    m_protocol->connectTo(host, port);
    emit statusChanged("Connecting to " + host + ":" + QString::number(port));
}

void TransferService::sendMessage(const QString &msg)
{
    if (!m_protocol) { emit statusChanged("Not initialised"); return; }
    m_protocol->sendMessage(msg);
}

void TransferService::sendFile(const QString &rawPath)
{
    if (!m_protocol) { emit statusChanged("Not initialised"); return; }

    QString path = rawPath;
    if (path.startsWith("file:///")) {
        path = path.mid(8);
#ifndef Q_OS_WIN
        path = "/" + path;
#endif
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        emit statusChanged("Cannot open: " + path);
        return;
    }

    QFileInfo info(path);
    const qint64 total = file.size();
    qint64 sent = 0;

    emit progress(0);
    emit statusChanged("Sending: " + info.fileName() +
                       "  (" + QString::number(total / 1024) + " KB)");

    m_protocol->sendFileStart(info.fileName(), total);

    const int chunkSize = m_protocol->maxChunkSize();
    while (!file.atEnd()) {
        QByteArray chunk = file.read(chunkSize);
        m_protocol->sendFileChunk(chunk);
        sent += chunk.size();
        int pct = total > 0 ? static_cast<int>((sent * 100) / total) : 0;
        emit progress(pct);
        QCoreApplication::processEvents();
    }

    m_protocol->sendFileEnd();
    emit progress(100);
    emit statusChanged("Sent: " + info.fileName());
}