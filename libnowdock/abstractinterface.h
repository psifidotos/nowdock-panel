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

    virtual void showDockAsNormal() = 0;
    virtual void showDockOnBottom() = 0;
    virtual void showDockOnTop() = 0;

Q_SIGNALS:
    void windowInAttention(bool);

protected:
    QQuickWindow *m_dockWindow;

};

}

#endif
