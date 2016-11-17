#include "panelwindow.h"

#include <QQuickWindow>
#include <QWindow>


PanelWindow::PanelWindow(QQuickWindow *parent) :
    QQuickWindow(parent)
{
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));
    setFlags(Qt::FramelessWindowHint|Qt::BypassWindowManagerHint|Qt::WindowStaysOnTopHint);
}


PanelWindow::~PanelWindow()
{
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


void PanelWindow::showEvent(QShowEvent *event)
{
    if ( !m_maskArea.isNull() ) {
        setMask(m_maskArea);
    }
}
