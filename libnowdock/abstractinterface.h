#ifndef ABSTRACTINTERFACE_H
#define ABSTRACTINTERFACE_H

#include <QObject>
#include <QQuickWindow>

namespace NowDock
{

class AbstractInterface : public QObject {
    Q_OBJECT

public:
    explicit AbstractInterface(QQuickWindow *parent);

    virtual bool dockIsCovered(QRect windowMaskArea = QRect()) = 0;
    virtual bool dockIsCovering(QRect windowMaskArea= QRect()) = 0;

    virtual void showDockAsNormal() = 0;
    virtual void showDockOnBottom() = 0;
    virtual void showDockOnTop() = 0;

Q_SIGNALS:
    void activeWindowChanged();
    void windowInAttention(bool);
    void windowChanged();

protected:
    QQuickWindow *m_dockWindow;

};

}

#endif
