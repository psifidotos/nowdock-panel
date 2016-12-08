#include "abstractinterface.h"

#include <QObject>
#include <QQuickWindow>

namespace NowDock
{

AbstractInterface::AbstractInterface(QQuickWindow *dock) :
    QObject(dock),
    m_dockNumber(0)
{
    m_dockWindow = dock;
}

void AbstractInterface::setDockNumber(unsigned int no)
{
    if (m_dockNumber == no) {
        return;
    }

    m_dockNumber = no;
}

unsigned int AbstractInterface::dockNumber() const
{
    return m_dockNumber;
}


void AbstractInterface::setMaskArea(QRect area)
{
    if (m_maskArea == area) {
        return;
    }

    m_maskArea = area;
}

}
