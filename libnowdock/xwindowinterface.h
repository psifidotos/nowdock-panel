#ifndef XWINDOWINTERFACE_H
#define XWINDOWINTERFACE_H

#include <QObject>

#include <KWindowInfo>

#include "abstractinterface.h"

namespace NowDock
{

class XWindowInterface : public AbstractInterface {
    Q_OBJECT

public:
    explicit XWindowInterface(QQuickWindow *parent);
    ~XWindowInterface();

    void showDockAsNormal();
    void showDockOnBottom();
    void showDockOnTop();

    bool desktopIsActive();
    bool dockIsCovered(QRect windowMaskArea = QRect());
    bool dockIsCovering(QRect windowMaskArea= QRect());

private Q_SLOTS:
    void activeWindowChanged(WId win);
    void windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2);
    void windowRemoved (WId id);

private:
    WId m_activeWindow;
    WId m_demandsAttention;

    bool isDesktop(WId id);
    bool isMaximized(KWindowInfo *info);
    bool isNormal(KWindowInfo *info);
    bool isOnBottom(KWindowInfo *info);
    bool isOnTop(KWindowInfo *info);
};

}

#endif




