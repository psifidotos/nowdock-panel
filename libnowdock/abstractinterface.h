#ifndef ABSTRACTINTERFACE_H
#define ABSTRACTINTERFACE_H

#include <QObject>
#include <QQuickWindow>

namespace NowDock
{

class AbstractInterface : public QObject {
    Q_OBJECT

public:
    explicit AbstractInterface(QQuickWindow *dock);

    virtual bool activeIsMaximized() const = 0;
    virtual bool desktopIsActive() const = 0;
    virtual bool dockIntersectsActiveWindow() const = 0;
    virtual bool dockIsCovered() const = 0;
    virtual bool dockIsCovering() const = 0;
    virtual bool dockIsOnTop() const = 0;
    virtual bool dockInNormalState() const = 0;
    virtual bool dockIsBelow() const = 0;

    //FIXME: This may not be needed, it would be better to investigate in KWindowSystem
    //its behavior when setting the window type to NET::Dock
    virtual void setDockDefaultFlags() = 0;
    virtual void setDockToAllDesktops() = 0;
    virtual void setDockToAlwaysVisible() = 0;
    virtual void showDockAsNormal() = 0;
    virtual void showDockOnBottom() = 0;
    virtual void showDockOnTop() = 0;

    void setMaskArea(QRect area);

Q_SIGNALS:
    void activeWindowChanged();
    void windowInAttention(bool);
    //FIXME: there is a chance that this signal is not needed at all
    void windowChanged();

protected:
    QRect m_maskArea;

    QQuickWindow *m_dockWindow;
};

}

#endif
