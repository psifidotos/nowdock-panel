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

private Q_SLOTS:
    void activeWindowChanged(WId win);
    void windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2);
    void windowRemoved (WId id);

private:
    WId m_activeWindow;
    WId m_demandsAttention;
};

}

#endif




