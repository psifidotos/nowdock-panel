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

    virtual bool desktopIsActive() = 0;
    virtual bool dockIsCovered() = 0;
    virtual bool dockIsCovering() = 0;

    virtual void showDockAsNormal() = 0;
    virtual void showDockOnBottom() = 0;
    virtual void showDockOnTop() = 0;

    void setMaskArea(QRect area);

Q_SIGNALS:
    void activeWindowChanged();
    void windowInAttention(bool);
    void windowChanged();

protected:
    QRect m_maskArea;

    QQuickWindow *m_dockWindow;
};

}

#endif
