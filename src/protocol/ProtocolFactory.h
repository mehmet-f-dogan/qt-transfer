#pragma once
#include "TcpProtocol.h"
#include "UdpProtocol.h"

class ProtocolFactory
{
public:
    static IProtocol *create(const QString &name)
    {
        if (name.compare(QLatin1String("TCP"), Qt::CaseInsensitive) == 0)
            return new TcpProtocol();

        if (name.compare(QLatin1String("UDP"), Qt::CaseInsensitive) == 0)
            return new UdpProtocol();

        return nullptr;
    }

    static QStringList availableProtocols()
    {
        return { "TCP", "UDP" };
    }
};