#include "abstractinterface.h"

#include <QObject>
#include <QQuickWindow>

namespace NowDock
{

AbstractInterface::AbstractInterface(QQuickWindow *dock) :
    QObject(dock)
{
    m_dockWindow = dock;
}

void AbstractInterface::setMaskArea(QRect area)
{
    if (m_maskArea == area) {
        return;
    }

    m_maskArea = area;
}

}
