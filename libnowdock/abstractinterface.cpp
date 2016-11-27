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

}
