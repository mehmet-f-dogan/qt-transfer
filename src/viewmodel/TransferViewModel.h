#pragma once
#include <QObject>
#include "../service/TransferService.h"

class TransferViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int     progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString status   READ status   NOTIFY statusChanged)

public:
    explicit TransferViewModel(TransferService *service, QObject *parent = nullptr);

    int     progress() const { return m_progress; }
    QString status()   const { return m_status;   }

    Q_INVOKABLE void init(const QString &proto);
    Q_INVOKABLE void startServer(int port);
    Q_INVOKABLE void connectTo(const QString &host, int port);
    Q_INVOKABLE void sendMessage(const QString &msg);
    Q_INVOKABLE void sendFile(const QString &path);

signals:
    void progressChanged(int value);
    void statusChanged(const QString &status);
    void messageReceived(const QString &msg);
    void fileReceived(const QString &path);

private slots:
    void onProgress(int value);
    void onStatusChanged(const QString &status);
    void onMessageReceived(const QString &msg);
    void onFileReceived(const QString &path);

private:
    TransferService *m_service;
    int     m_progress = 0;
    QString m_status   = "Not initialised — select a protocol and connect.";
};