#include "panelwindow.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>
#include <QWindow>

#include <KWindowEffects>
#include <KWindowInfo>
#include <KWindowSystem>

#include <QDebug>

namespace NowDock
{

PanelWindow::PanelWindow(QQuickWindow *parent) :
    QQuickWindow(parent),
    m_secondInitPass(false),
    m_demandsAttention(-1),
    m_windowIsInAttention(false),
    m_isHovered(false)
{    
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);

    connect(KWindowSystem::self(), SIGNAL(activeWindowChanged(WId)), this, SLOT(activeWindowChanged(WId)));
    connect(KWindowSystem::self(), SIGNAL(windowChanged (WId,NET::Properties,NET::Properties2)), this, SLOT(windowChanged (WId,NET::Properties,NET::Properties2)));
    connect(KWindowSystem::self(), SIGNAL(windowRemoved(WId)), this, SLOT(windowRemoved(WId)));
    m_activeWindow = KWindowSystem::activeWindow();

    m_updateStateTimer.setSingleShot(true);
    m_updateStateTimer.setInterval(1500);
    connect(&m_updateStateTimer, &QTimer::timeout, this, &PanelWindow::updateState);

    m_initTimer.setSingleShot(true);
    m_initTimer.setInterval(500);
    connect(&m_initTimer, &QTimer::timeout, this, &PanelWindow::initWindow);

    connect(this, SIGNAL(panelVisibilityChanged()), this, SLOT(updateVisibilityFlags()));
    setPanelVisibility(BelowActive);
    updateVisibilityFlags();

    connect(this, SIGNAL(locationChanged()), this, SLOT(updateWindowPosition()));
}

PanelWindow::~PanelWindow()
{
    qDebug() << "Destroying Now Dock - Magic Window";
}

QRect PanelWindow::maskArea() const
{
    return m_maskArea;
}

void PanelWindow::setMaskArea(QRect area)
{
    if (m_maskArea == area) {
        return;
    }

    m_maskArea = area;
    setMask(m_maskArea);
    emit maskAreaChanged();
}

Plasma::Types::Location PanelWindow::location() const
{
    return m_location;
}

void PanelWindow::setLocation(Plasma::Types::Location location)
{
    if (m_location == location) {
        return;
    }

    m_location = location;
    emit locationChanged();
}

PanelWindow::PanelVisibility PanelWindow::panelVisibility() const
{
    return m_panelVisibility;
}

void PanelWindow::setPanelVisibility(PanelWindow::PanelVisibility state)
{
    if (m_panelVisibility == state) {
        return;
    }

    m_panelVisibility = state;
    emit panelVisibilityChanged();
}


bool PanelWindow::windowInAttention() const
{
    return m_windowIsInAttention;
}

void PanelWindow::setWindowInAttention(bool state)
{
    if (m_windowIsInAttention == state) {
        return;
    }

    m_windowIsInAttention = state;
    emit windowInAttentionChanged();
}

bool PanelWindow::isHovered() const
{
    return m_isHovered;
}

void PanelWindow::setIsHovered(bool state)
{
    if (m_isHovered == state) {
        return;
    }

    m_isHovered = state;
    emit isHoveredChanged();
}


/*******************************/

void PanelWindow::initialize()
{
    m_secondInitPass = true;
    m_initTimer.start();
}

void PanelWindow::initWindow()
{
    updateVisibilityFlags();
    shrinkTransient();
    updateWindowPosition();

    // The initialization phase makes two passes because
    // changing the window style and type wants a small delay
    // and afterwards the second pass positions them correctly
    if(m_secondInitPass) {
        m_initTimer.start();
        m_secondInitPass = false;
    }
}

void PanelWindow::shrinkTransient()
{
    if (transientParent()) {
        int newSize = 15;
        int transWidth = transientParent()->width();
        int transHeight = transientParent()->height();
        int centerX = x()+width()/2;
        int centerY = y()+height()/2;

        if (m_location == Plasma::Types::BottomEdge) {
            transientParent()->setMinimumHeight(0);
            transientParent()->setHeight(newSize);
            transientParent()->setY(screen()->size().height() - newSize);
            transientParent()->setX(centerX - transWidth/2);
        } else if (m_location == Plasma::Types::TopEdge) {
            transientParent()->setMinimumHeight(0);
            transientParent()->setHeight(newSize);
            transientParent()->setY(0);
            transientParent()->setX(centerX - transWidth/2);
        } else if (m_location == Plasma::Types::LeftEdge) {
            transientParent()->setMinimumWidth(0);
            transientParent()->setWidth(newSize);
            transientParent()->setX(0);
            transientParent()->setY(centerY - transHeight/2);
        } else if (m_location == Plasma::Types::RightEdge) {
            transientParent()->setMinimumWidth(0);
            transientParent()->setWidth(newSize);
            transientParent()->setX(screen()->size().width() - newSize);
            transientParent()->setY(centerY - transHeight/2);
        }
    }
}

void PanelWindow::updateWindowPosition()
{
    if (m_location == Plasma::Types::BottomEdge) {
        setX(0);
        setY(screen()->size().height() - height());
    } else if (m_location == Plasma::Types::TopEdge) {
        setX(0);
        setY(0);
    } else if (m_location == Plasma::Types::LeftEdge) {
        setX(0);
        setY(0);
    } else if (m_location == Plasma::Types::RightEdge) {
        setX(screen()->size().width() - width());
        setY(0);
    }
}

void PanelWindow::updateVisibilityFlags()
{
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);
    updateWindowPosition();

    if (m_panelVisibility == LetWindowsCover) {
        m_updateStateTimer.start();
    } else if (m_panelVisibility == WindowsGoBelow) {
        showOnTop();
    } else if (m_panelVisibility == BelowActive) {
        showOnTop();
        m_updateStateTimer.start();
    } else if (m_panelVisibility == AlwaysVisible) {
        KWindowSystem::setType(winId(), NET::Dock);
        updateWindowPosition();
    }
}

/*
 * It is used from the m_updateStateTimer in order to check the dock's
 * visibility and trigger events and actions which are needed to
 * respond accordingly
 */
void PanelWindow::updateState()
{
    //FIXME: check also
    // the screen in which are active and the dock
    KWindowInfo dockInfo(winId(), NET::WMState);

    if (m_panelVisibility == BelowActive) {
        KWindowInfo activeInfo(m_activeWindow, NET::WMGeometry);

        if ( activeInfo.valid() ) {
            QRect maskSize;

            if ( !m_maskArea.isNull() ) {
                maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
            } else {
                maskSize = QRect(x(), y(), width(), height());
            }

            if ( !isDesktop(m_activeWindow) && maskSize.intersects(activeInfo.geometry()) ) {
                if ( isOnTop(&dockInfo) ) {
                    if (!m_isHovered && !m_windowIsInAttention) {
                        mustBeLowered();                    //showNormal();
                    }
                } else {
                    if ( m_windowIsInAttention ) {
                        mustBeRaised();                     //showOnTop();
                    }
                }
            } else if (isNormal(&dockInfo)){
                if(!isDesktop(m_activeWindow) && dockIsCovered()) {
                    mustBeRaised();
                } else {
                    showOnTop();
                }
            }
        }
    } else if (m_panelVisibility == BelowMaximized) {
        KWindowInfo activeInfo(m_activeWindow, NET::WMState);

        if ( isMaximized(&activeInfo) ) {
            if (isOnTop(&dockInfo)) {
                mustBeLowered();     //showNormal();
            }
        } else if (isNormal(&dockInfo)){
            mustBeRaised();     //showOnTop();
        }

    } else if (m_panelVisibility == LetWindowsCover){
        if (isOnTop(&dockInfo) || isNormal(&dockInfo)) {
            mustBeLowered();  //showOnBottom();
        }
    }
}

void PanelWindow::showOnTop()
{
    //    qDebug() << "reached make top...";
    KWindowSystem::clearState(winId(), NET::KeepBelow);
    KWindowSystem::setState(winId(), NET::KeepAbove);
}

void PanelWindow::showNormal()
{
    //    qDebug() << "reached make normal...";
    KWindowSystem::clearState(winId(), NET::KeepAbove);
    KWindowSystem::clearState(winId(), NET::KeepBelow);
}

void PanelWindow::showOnBottom()
{
    //    qDebug() << "reached make bottom...";
    KWindowSystem::clearState(winId(), NET::KeepAbove);
    KWindowSystem::setState(winId(), NET::KeepBelow);
}


bool PanelWindow::isMaximized(KWindowInfo *info)
{
    if ( !info || !info->valid() ) {
        return false;
    }

    return ( info->hasState(NET::Max) );
}

bool PanelWindow::isNormal(KWindowInfo *info)
{
    if ( !info || !info->valid() ) {
        return false;
    }

    return ( !isOnBottom(info) && !isOnTop(info) );
}

bool PanelWindow::isOnBottom(KWindowInfo *info)
{
    if ( !info || !info->valid() ) {
        return false;
    }

    return ( info->hasState(NET::KeepBelow) );
}

bool PanelWindow::isOnTop(KWindowInfo *info)
{
    if ( !info || !info->valid() ) {
        return false;
    }

    return ( info->hasState(NET::KeepAbove) );
}


bool PanelWindow::dockIsCovered()
{
    int currentDockPos = -1;

    QList<WId> windows = KWindowSystem::stackingOrder();
    int size = windows.count();

    for(int i=size-1; i>=0; --i) {
        WId window = windows.at(i);
        if (window == winId()) {
            currentDockPos = i;
            break;
        }
    }

    if (currentDockPos >=0) {
        QRect maskSize;

        if ( !m_maskArea.isNull() ) {
            maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
        } else {
            maskSize = QRect(x(), y(), width(), height());
        }

        for(int j=size-1; j>currentDockPos; --j) {
            WId window = windows.at(j);

            KWindowInfo info(window, NET::WMGeometry);

            if ( info.valid() && maskSize.intersects(info.geometry()) ) {
                return true;
            }
        }
    }

    return false;
}

bool PanelWindow::activeWindowAboveDock()
{
    int currentDockPos = -1;

    QList<WId> windows = KWindowSystem::stackingOrder();
    int size = windows.count();

    for(int i=size-1; i>=0; --i) {
        WId window = windows.at(i);
        if (window == winId()) {
            currentDockPos = i;
            break;
        }
    }

    if (currentDockPos >=0) {
        for(int j=size-1; j>currentDockPos; --j) {
            WId window = windows.at(j);
            if (window == m_activeWindow) {
                return true;
            }
        }
    }

    return false;
}

bool PanelWindow::isDesktop(WId id)
{
    KWindowInfo info(id, NET::WMWindowType);

    if ( !info.valid() ) {
        return false;
    }

    NET::WindowType type = info.windowType(NET::DesktopMask|NET::DockMask|NET::DialogMask);

    return type == NET::Desktop;
}


/***************/

void PanelWindow::showEvent(QShowEvent *event)
{
    if ( !m_maskArea.isNull() ) {
        setMask(m_maskArea);
    }
}

bool PanelWindow::event(QEvent *e)
{
    QQuickWindow::event(e);

    if (e->type() == QEvent::Enter) {
        setIsHovered(true);
        m_updateStateTimer.stop();
        shrinkTransient();
        showOnTop();
    } else if ((e->type() == QEvent::Leave) && (!isActive()) ) {
        setIsHovered(false);
        m_updateStateTimer.start();
    }
}

void PanelWindow::activeWindowChanged(WId win)
{
    m_activeWindow = win;
    if (!m_updateStateTimer.isActive()) {
        m_updateStateTimer.start();
    }
}

void PanelWindow::windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2)
{
    KWindowInfo info(id, NET::WMState|NET::CloseWindow);
    if (info.valid()) {
        if ((m_demandsAttention == -1) && info.hasState(NET::DemandsAttention)) {
            m_demandsAttention = id;
            setWindowInAttention(true);
        } else if ((m_demandsAttention == id) && !info.hasState(NET::DemandsAttention)) {
            m_demandsAttention = -1;
            setWindowInAttention(false);
        }
    }

    if ((m_panelVisibility!=BelowActive)&&(m_panelVisibility!=BelowMaximized)) {
        return;
    }

    if ((id==m_activeWindow) && (!m_updateStateTimer.isActive())) {
        m_updateStateTimer.start();
    }
}

void PanelWindow::windowRemoved (WId id)
{
    if (id==m_demandsAttention) {
        m_demandsAttention = -1;
        setWindowInAttention(false);
    }
}

} //NowDock namespace
