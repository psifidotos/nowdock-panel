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

    bool dockIntersectsActiveWindow() const;
    bool desktopIsActive() const;
    bool dockIsCovered() const;
    bool dockIsCovering() const;
    bool dockIsOnTop() const;
    bool dockInNormalState() const;
    bool dockIsBelow() const;

private Q_SLOTS:
    void activeWindowChanged(WId win);
    void windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2);
    void windowRemoved (WId id);

private:
    WId m_activeWindow;
    WId m_demandsAttention;

    bool isDesktop(WId id) const;
    bool isMaximized(WId id) const;
    bool isNormal(WId id) const;
    bool isOnBottom(WId id) const;
    bool isOnTop(WId id) const;
};

}

#endif




