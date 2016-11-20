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
    QQuickWindow(parent)
{    
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));

    // setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);

    connect(KWindowSystem::self(), SIGNAL(activeWindowChanged(WId)), this, SLOT(activeWindowChanged(WId)));

    // KWindowSystem::setOnAllDesktops(winId(), true);

    m_hideTimer.setSingleShot(true);
    m_hideTimer.setInterval(400);
    connect(&m_hideTimer, &QTimer::timeout, this, &PanelWindow::hide);

    connect(this, SIGNAL(panelVisibilityChanged()), this, SLOT(updateVisibilityFlags()));
    setPanelVisibility(BelowActive);

    //  setFlags(Qt::FramelessWindowHint|Qt::BypassWindowManagerHint); //|Qt::WindowStaysOnTopHint
}

/*PanelWindow::~PanelWindow()
{
}*/

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

void PanelWindow::shrinkTransient()
{
    if (transientParent()) {
        int newSize = 20;
        transientParent()->setY(screen()->size().height() - newSize);
        transientParent()->setMinimumHeight(0);
        transientParent()->setHeight(newSize);
    }
}

void PanelWindow::updateVisibilityFlags()
{
    setFlags(Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);
    setY(screen()->size().height() - height());

    if (m_panelVisibility == LetWindowsCover) {
        showOnTop();
    } else if (m_panelVisibility == WindowsGoBelow) {
        m_hideTimer.start();
    } else if (m_panelVisibility == BelowActive) {
        showOnTop();
        m_hideTimer.start();
    } else if ((m_panelVisibility == AlwaysVisible) || (m_panelVisibility == AlwaysVisibleFree)) {
        KWindowSystem::setType(winId(), NET::Dock);
        setY(screen()->size().height() - height());
    }
}

void PanelWindow::hide()
{
    //FIXME: check also
    // the screen in which are active and the dock
    if( m_panelVisibility == BelowActive) {
        WId activeWId = KWindowSystem::activeWindow();
        KWindowInfo activeInfo(activeWId, NET::WMGeometry);

        QRect maskSize;

        if ( !m_maskArea.isNull() ) {
            maskSize = QRect(x()+m_maskArea.x(), y()+m_maskArea.y(), m_maskArea.width(), m_maskArea.height());
        } else {
            maskSize = QRect(x(), y(), width(), height());
        }

        if (activeInfo.valid() && maskSize.intersects(activeInfo.geometry()) ) {
            KWindowSystem::clearState(winId(), NET::KeepAbove);
        }
    } else if (m_panelVisibility == WindowsGoBelow){
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
    m_hideTimer.start();
}

} //NowDock namespace
