#include "xwindowinterface.h"

#include <KWindowInfo>
#include <KWindowSystem>

namespace NowDock
{

XWindowInterface::XWindowInterface(QQuickWindow *parent) :
    AbstractInterface(parent),
    m_demandsAttention(-1)
{
    m_activeWindow = KWindowSystem::activeWindow();

    connect(KWindowSystem::self(), SIGNAL(activeWindowChanged(WId)), this, SLOT(activeWindowChanged(WId)));
    connect(KWindowSystem::self(), SIGNAL(windowChanged (WId,NET::Properties,NET::Properties2)), this, SLOT(windowChanged (WId,NET::Properties,NET::Properties2)));
    connect(KWindowSystem::self(), SIGNAL(windowRemoved(WId)), this, SLOT(windowRemoved(WId)));
}

XWindowInterface::~XWindowInterface()
{
}

void XWindowInterface::showDockOnTop()
{
    KWindowSystem::clearState(m_dockWindow->winId(), NET::KeepBelow);
    KWindowSystem::setState(m_dockWindow->winId(), NET::KeepAbove);
}

void XWindowInterface::showDockAsNormal()
{
    //    qDebug() << "reached make normal...";
    KWindowSystem::clearState(m_dockWindow->winId(), NET::KeepAbove);
    KWindowSystem::clearState(m_dockWindow->winId(), NET::KeepBelow);
}

void XWindowInterface::showDockOnBottom()
{
    //    qDebug() << "reached make bottom...";
    KWindowSystem::clearState(m_dockWindow->winId(), NET::KeepAbove);
    KWindowSystem::setState(m_dockWindow->winId(), NET::KeepBelow);
}

/*
 * SLOTS
 */

void XWindowInterface::activeWindowChanged(WId win)
{
    m_activeWindow = win;
}

void XWindowInterface::windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2)
{
    KWindowInfo info(id, NET::WMState|NET::CloseWindow);

    if (info.valid()) {
        if ((m_demandsAttention == -1) && info.hasState(NET::DemandsAttention)) {
            m_demandsAttention = id;
            emit windowInAttention(true);
            //setWindowInAttention(true);
        } else if ((m_demandsAttention == id) && !info.hasState(NET::DemandsAttention)) {
            m_demandsAttention = -1;
            emit windowInAttention(false);
            //setWindowInAttention(false);
        }
    }
}

void XWindowInterface::windowRemoved (WId id)
{
    if (id==m_demandsAttention) {
        m_demandsAttention = -1;
        emit windowInAttention(false);
    }
}




}
