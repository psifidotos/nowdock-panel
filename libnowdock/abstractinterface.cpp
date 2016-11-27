#include "abstractinterface.h"

#include <QObject>
#include <QQuickWindow>

namespace NowDock
{

AbstractInterface::AbstractInterface(QQuickWindow *parent) :
    QObject(parent)
{
    m_dockWindow = parent;
}

}
