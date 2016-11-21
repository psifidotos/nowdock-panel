#include "panelwindow.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>
#include <QWindow>

#include <kwindoweffects.h>
#include <kwindowinfo.h>
#include <kwindowsystem.h>

#include <QDebug>

namespace NowDock
{

PanelWindow::PanelWindow(QQuickWindow *parent) :
    QQuickWindow(parent),
    m_secondInitPass(false)
{    
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);

    connect(KWindowSystem::self(), SIGNAL(activeWindowChanged(WId)), this, SLOT(activeWindowChanged(WId)));
    m_activeWindow = KWindowSystem::activeWindow();

    m_hideTimer.setSingleShot(true);
    m_hideTimer.setInterval(400);
    connect(&m_hideTimer, &QTimer::timeout, this, &PanelWindow::hide);

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
    qDebug() << "Destroying window called";
    // close();
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
        m_hideTimer.start();
    } else if (m_panelVisibility == WindowsGoBelow) {
        showOnTop();
    } else if (m_panelVisibility == BelowActive) {
        showOnTop();
        m_hideTimer.start();
    } else if (m_panelVisibility == AlwaysVisible) {
        KWindowSystem::setType(winId(), NET::Dock);
        updateWindowPosition();
    }
}

void PanelWindow::hide()
{
    //FIXME: check also
    // the screen in which are active and the dock
    if (m_panelVisibility == BelowActive) {
        KWindowInfo activeInfo(m_activeWindow, NET::WMGeometry);

        if ( activeInfo.valid() ) {
            QRect maskSize;

            if ( !m_maskArea.isNull() ) {
                maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
            } else {
                maskSize = QRect(x(), y(), width(), height());
            }

            if (maskSize.intersects(activeInfo.geometry()) ) {
                KWindowSystem::clearState(winId(), NET::KeepAbove);
            } else {
                KWindowSystem::setState(winId(), NET::KeepAbove);
            }
        }
    }else if (m_panelVisibility == BelowMaximized) {
        KWindowInfo activeInfo(m_activeWindow, NET::WMState);

        if ( activeInfo.valid() ) {
            if (activeInfo.hasState(NET::Max)) {
                KWindowSystem::clearState(winId(), NET::KeepAbove);
            } else {
                KWindowSystem::setState(winId(), NET::KeepAbove);
            }
        }
    } else if (m_panelVisibility == LetWindowsCover){
        KWindowSystem::clearState(winId(), NET::KeepAbove);
        KWindowSystem::setState(winId(), NET::KeepBelow);
    }

}

void PanelWindow::showOnTop()
{
    KWindowSystem::clearState(winId(), NET::KeepBelow);
    KWindowSystem::setState(winId(), NET::KeepAbove);
}

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
        m_hideTimer.stop();
        shrinkTransient();
        showOnTop();
    } else if ((e->type() == QEvent::Leave) && (!isActive()) ) {
        m_hideTimer.start();
    }
}

void PanelWindow::activeWindowChanged(WId win)
{
    m_activeWindow = win;
    m_hideTimer.start();
}

} //NowDock namespace
