#include "panelwindow.h"

#include "xwindowinterface.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>
#include <QWindow>

//#include <KWindowEffects>
#include <KWindowInfo>
#include <KWindowSystem>

#include <QDebug>

namespace NowDock
{

PanelWindow::PanelWindow(QQuickWindow *parent) :
    QQuickWindow(parent),
    m_secondInitPass(false),
    m_isAutoHidden(false),
    m_childrenLength(-1),
    m_demandsAttention(-1),
    m_windowIsInAttention(false),
    m_disableHiding(false),
    m_isHovered(false)
{    
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);

    m_interface = new XWindowInterface(this);
    connect(m_interface, SIGNAL(windowInAttention(bool)), this, SLOT(setWindowInAttention(bool)));
    connect(m_interface, SIGNAL(windowChanged()), this, SLOT(windowChanged()));
    connect(m_interface, SIGNAL(activeWindowChanged()), this, SLOT(activeWindowChanged()));

    connect(KWindowSystem::self(), SIGNAL(activeWindowChanged(WId)), this, SLOT(activeWindowChanged(WId)));
    m_activeWindow = KWindowSystem::activeWindow();

    m_screen = screen();
    connect(this, SIGNAL(screenChanged(QScreen *)), this, SLOT(screenChanged(QScreen *)));
    if (m_screen) {
        connect(m_screen, SIGNAL(geometryChanged(const QRect &)), this, SIGNAL(screenGeometryChanged()));
    }

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
    connect(this, SIGNAL(windowInAttentionChanged()), this, SLOT(updateState()));
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

QRect PanelWindow::screenGeometry() const
{
    return (m_screen ? m_screen->geometry() : QRect());
}

bool PanelWindow::isAutoHidden() const
{
    return m_isAutoHidden;
}

void PanelWindow::setIsAutoHidden(bool state)
{
    if (m_isAutoHidden == state) {
        return;
    }

    m_isAutoHidden = state;
    emit isAutoHiddenChanged();
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

int PanelWindow::childrenLength() const
{
    return m_childrenLength;
}

void PanelWindow::setChildrenLength(int value)
{
    if (m_childrenLength == value) {
        return;
    }

    m_childrenLength = value;
    emit childrenLengthChanged();
}

bool PanelWindow::disableHiding() const
{
    return m_disableHiding;
}

void PanelWindow::setDisableHiding(bool value)
{
    if (m_disableHiding == value) {
        return;
    }

    m_disableHiding = value;

    emit disableHidingChanged();

    if (!m_disableHiding) {
        m_updateStateTimer.start();
    }
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

        QWindow *transient = transientParent();
        int screenLength = ((m_location == Plasma::Types::BottomEdge) || (m_location == Plasma::Types::TopEdge)) ?
                    m_screen->geometry().width() : m_screen->geometry().height();

        int tempLength = qMax(screenLength/2, m_childrenLength);

        if (transient) {
            if (m_location == Plasma::Types::BottomEdge) {
                transient->setMinimumHeight(0);
                transient->setHeight(newSize);
                transient->setMinimumWidth(tempLength);
                transient->setWidth(tempLength);

                transient->setY(screen()->size().height() - newSize);
                transient->setX(centerX - transWidth/2);
            } else if (m_location == Plasma::Types::TopEdge) {
                transient->setMinimumHeight(0);
                transient->setHeight(newSize);
                transient->setMinimumWidth(tempLength);
                transient->setWidth(tempLength);

                transient->setY(0);
                transient->setX(centerX - transWidth/2);
            } else if (m_location == Plasma::Types::LeftEdge) {
                transient->setMinimumWidth(0);
                transient->setWidth(newSize);
                transient->setMinimumHeight(tempLength);
                transient->setHeight(tempLength);

                transient->setX(0);
                transient->setY(centerY - transHeight/2);
            } else if (m_location == Plasma::Types::RightEdge) {
                transient->setMinimumWidth(0);
                transient->setWidth(newSize);
                transient->setMinimumHeight(tempLength);
                transient->setHeight(tempLength);

                transient->setX(screen()->size().width() - newSize);
                transient->setY(centerY - transHeight/2);
            }
        }
    }
}

void PanelWindow::updateWindowPosition()
{
    if (m_location == Plasma::Types::BottomEdge) {
        setX(m_screen->geometry().x());
        setY(m_screen->geometry().height() - height());
    } else if (m_location == Plasma::Types::TopEdge) {
        setX(m_screen->geometry().x());
        setY(m_screen->geometry().y());
    } else if (m_location == Plasma::Types::LeftEdge) {
        setX(m_screen->geometry().x());
        setY(m_screen->geometry().y());
    } else if (m_location == Plasma::Types::RightEdge) {
        setX(m_screen->geometry().width() - width());
        setY(m_screen->geometry().y());
    }
}

void PanelWindow::updateVisibilityFlags()
{
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);

    if (m_panelVisibility == AlwaysVisible) {
        KWindowSystem::setType(winId(), NET::Dock);
        updateWindowPosition();
    } else {
        updateWindowPosition();
        showOnTop();
        m_updateStateTimer.start();
    }

    if (m_panelVisibility == AutoHide) {
        m_updateStateTimer.setInterval(2500);
    } else {
        m_updateStateTimer.setInterval(1500);
    }
}

/*
 * It is used from the m_updateStateTimer in order to check the dock's
 * visibility and trigger events and actions which are needed to
 * respond accordingly
 */
void PanelWindow::updateState()
{
    KWindowInfo dockInfo(winId(), NET::WMState);
    KWindowInfo activeInfo(m_activeWindow, NET::WMGeometry | NET::WMState);

    //qDebug() << "in update state disableHiding:" <<m_disableHiding;

    switch (m_panelVisibility) {
    case BelowActive:
        if ( activeInfo.valid() ) {
            QRect maskSize;

            if ( !m_maskArea.isNull() ) {
                maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
            } else {
                maskSize = QRect(x(), y(), width(), height());
            }

            if ( !isDesktop(m_activeWindow) && maskSize.intersects(activeInfo.geometry()) ) {
                if ( isOnTop(&dockInfo) ) {
                    if (!m_isHovered && !m_windowIsInAttention && !m_disableHiding) {
                        mustBeLowered();                    //showNormal();
                    }
                } else {
                    if ( m_windowIsInAttention ) {
                        mustBeRaised();                     //showOnTop();
                    }
                }
            } else if (isNormal(&dockInfo)){
                if(!isDesktop(m_activeWindow) && m_interface->dockIsCovered(m_maskArea)) {
                    mustBeRaised();
                } else {
                    showOnTop();
                }
            }
        }
        break;
    case BelowMaximized:
        if ( activeInfo.valid() ) {
            QRect maskSize;

            if ( !m_maskArea.isNull() ) {
                maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
            } else {
                maskSize = QRect(x(), y(), width(), height());
            }

            if ( !isDesktop(m_activeWindow) && isMaximized(&activeInfo) && maskSize.intersects(activeInfo.geometry()) ) {
                if ( isOnTop(&dockInfo) ) {
                    if (!m_isHovered && !m_windowIsInAttention && !m_disableHiding) {
                        mustBeLowered();                    //showNormal();
                    }
                } else {
                    if ( m_windowIsInAttention ) {
                        mustBeRaised();                     //showOnTop();
                    }
                }
            } else if (isNormal(&dockInfo)){
                if(!isDesktop(m_activeWindow) && m_interface->dockIsCovered(m_maskArea)) {
                    mustBeRaised();
                } else {
                    showOnTop();
                }
            }
        }
        break;
    case LetWindowsCover:
        if (!m_isHovered && isOnTop(&dockInfo)) {
            if( m_interface->dockIsCovering(m_maskArea)  ) {
                if (!m_disableHiding) {
                    mustBeLowered();
                }
            } else {
                showOnBottom();
            }
        } else if ( m_windowIsInAttention ) {
            if( !isOnTop(&dockInfo) ) {
                if (m_interface->dockIsCovered(m_maskArea)) {
                    mustBeRaised();
                } else {
                    showOnTop();
                }
            }
        }
        break;
    case WindowsGoBelow:
        //Do nothing, the dock is OnTop state in every case
        break;
    case AutoHide:
        if (m_windowIsInAttention && m_isAutoHidden) {
            emit mustBeRaised();
        } else if (!m_isHovered && !m_disableHiding) {
            emit mustBeLowered();
        }
        break;
    case AlwaysVisible:
        //Do nothing, the dock in OnTop state in every case
        break;
    }
}

void PanelWindow::showOnTop()
{
    //    qDebug() << "reached make top...";
    m_interface->showDockOnTop();
}

void PanelWindow::showNormal()
{
    //    qDebug() << "reached make normal...";
    m_interface->showDockAsNormal();
}

void PanelWindow::showOnBottom()
{
    //    qDebug() << "reached make bottom...";
    m_interface->showDockOnBottom();
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


/***************/

void PanelWindow::activeWindowChanged(WId win)
{
    m_activeWindow = win;

 /*   if ( (m_panelVisibility == WindowsGoBelow)
         || (m_panelVisibility == AlwaysVisible)
         || (m_panelVisibility == AutoHide)) {
        return;
    }

    if (!m_updateStateTimer.isActive()) {
        m_updateStateTimer.start();
    }*/
}

void PanelWindow::activeWindowChanged()
{
    if ( (m_panelVisibility == WindowsGoBelow)
         || (m_panelVisibility == AlwaysVisible)
         || (m_panelVisibility == AutoHide)) {
        return;
    }

    if (!m_updateStateTimer.isActive()) {
        m_updateStateTimer.start();
    }
}

bool PanelWindow::event(QEvent *e)
{
    QQuickWindow::event(e);

    if (e->type() == QEvent::Enter) {
        setIsHovered(true);
        m_updateStateTimer.stop();
        shrinkTransient();

        if (m_panelVisibility == AutoHide) {
            if (m_isAutoHidden) {
                emit mustBeRaised();
            }
        } else {
            showOnTop();
        }
    } else if ((e->type() == QEvent::Leave) && (!isActive()) ) {
        setIsHovered(false);

        if ( (m_panelVisibility != WindowsGoBelow)
             && (m_panelVisibility != AlwaysVisible) ) {
            m_updateStateTimer.start();
        }
    }
}

void PanelWindow::screenChanged(QScreen *screen)
{
    if (screen) {
        if (m_screen) {
            disconnect(m_screen, SIGNAL(geometryChanged(const QRect &)), this, SIGNAL(screenGeometryChanged()));
        }

        m_screen = screen;
        connect(m_screen, SIGNAL(geometryChanged(const QRect &)), this, SIGNAL(screenGeometryChanged()));

        emit screenGeometryChanged();
    }
}

void PanelWindow::showEvent(QShowEvent *event)
{
    if ( !m_maskArea.isNull() ) {
        setMask(m_maskArea);
    }
}


void PanelWindow::windowChanged ()
{
/*    if ((m_panelVisibility!=BelowActive)&&(m_panelVisibility!=BelowMaximized)) {
        return;
    }

    if ((id==m_activeWindow) && (!m_updateStateTimer.isActive())) {
        m_updateStateTimer.start();
    }*/
}


} //NowDock namespace
