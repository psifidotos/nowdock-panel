#ifndef PANELWINDOW_H
#define PANELWINDOW_H

#include <QMenu>
#include <QQuickWindow>
#include <QTimer>

#include <plasma/plasma.h>

#include <Plasma/Applet>
#include <Plasma/Containment>
#include <PlasmaQuick/AppletQuickItem>

#include "abstractinterface.h"

namespace NowDock
{

class PanelWindow : public QQuickWindow {
    Q_OBJECT
    Q_ENUMS(PanelVisibility)
    Q_ENUMS(Alignment)

    Q_PROPERTY(bool immutable READ immutable WRITE setImmutable NOTIFY immutableChanged)

    Q_PROPERTY(bool isAutoHidden READ isAutoHidden WRITE setIsAutoHidden NOTIFY isAutoHiddenChanged)

    Q_PROPERTY(bool isHovered READ isHovered NOTIFY isHoveredChanged)

    Q_PROPERTY(bool disableHiding READ disableHiding WRITE setDisableHiding NOTIFY disableHidingChanged)

    Q_PROPERTY(bool windowInAttention READ windowInAttention WRITE setWindowInAttention NOTIFY windowInAttentionChanged)

    Q_PROPERTY(int childrenLength READ childrenLength WRITE setChildrenLength NOTIFY childrenLengthChanged)

    Q_PROPERTY(unsigned int maximumLength READ maximumLength NOTIFY maximumLengthChanged)

    /**
     * the window mask, can be used in real transparent panels that set only the visual area
     * of the window
     * @since 5.8
     */
    Q_PROPERTY(QRect maskArea READ maskArea WRITE setMaskArea NOTIFY maskAreaChanged)

    /**
     * the dock's screen geometry, e.g. it is used to set correctly x, y values
     */
    Q_PROPERTY(QRect screenGeometry READ screenGeometry NOTIFY screenGeometryChanged)

    Q_PROPERTY(Plasma::Types::Location location READ location WRITE setLocation NOTIFY locationChanged)

    Q_PROPERTY(PanelVisibility panelVisibility READ panelVisibility WRITE setPanelVisibility NOTIFY panelVisibilityChanged)

public:
    enum PanelVisibility {
        BelowActive = 0, /** always visible except if ovelaps with the active window, no area reserved */
        BelowMaximized, /** always visible except if ovelaps with an active maximize window, no area reserved */
        LetWindowsCover, /** always visible, windows will go over the panel, no area reserved */
        WindowsGoBelow, /** default, always visible, windows will go under the panel, no area reserved */
        AutoHide, /** the panel will be shownn only if the mouse cursor is on screen edges */
        AlwaysVisible,  /** always visible panel, "Normal" plasma panel, accompanies plasma's "Always Visible"  */
    };

    enum Alignment {
        Center = 0,
        Left,
        Right,
        Top,
        Bottom,
        Double=10
    };

    explicit PanelWindow(QQuickWindow *parent = Q_NULLPTR);
    ~PanelWindow();

    bool disableHiding() const;
    void setDisableHiding(bool state);

    bool immutable() const;
    void setImmutable(bool state);

    bool isAutoHidden() const;
    void setIsAutoHidden(bool state);

    bool isHovered() const;

    bool windowInAttention() const;
   // void setWindowInAttention(bool state);

    int childrenLength() const;
    void setChildrenLength(int value);

    unsigned int maximumLength() const;

    QRect maskArea() const;
    void setMaskArea(QRect area);

    QRect screenGeometry() const;

    Plasma::Types::Location location() const;
    void setLocation(Plasma::Types::Location location);

    PanelVisibility panelVisibility() const;
    void setPanelVisibility(PanelVisibility state);

Q_SIGNALS:
    void childrenLengthChanged();
    void disableHidingChanged();
    void immutableChanged();
    void isAutoHiddenChanged();
    void isHoveredChanged();
    void locationChanged();
    void maskAreaChanged();
    void maximumLengthChanged();
    void mustBeRaised(); //are used to triger the sliding animations from the qml part
    void mustBeLowered();
    void panelVisibilityChanged();
    void screenGeometryChanged();
    void windowInAttentionChanged();

public slots:
    Q_INVOKABLE void addAppletItem(QObject *item);
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void removeAppletItem(QObject *item);
    Q_INVOKABLE void showNormal();
    Q_INVOKABLE void showOnTop();
    Q_INVOKABLE void showOnBottom();
    Q_INVOKABLE void shrinkTransient();
    void setWindowInAttention(bool state);


protected:
    bool event(QEvent *event) override;
    void mousePressEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void mouseReleaseEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void showEvent(QShowEvent *event) override;
  //  void mouseMoveEvent(QMouseEvent *ev);

private Q_SLOTS:
    void activeWindowChanged();
    void updateState();
    void initWindow();
    void menuAboutToHide();
    void setIsHovered(bool state);
    void screenChanged(QScreen *screen);
    void updateVisibilityFlags();
    void updateWindowPosition();

private:
    bool m_disableHiding;
    bool m_immutable;
    bool m_isAutoHidden;
    bool m_isHovered;
    //second pass of the initialization
    bool m_secondInitPass;
    bool m_windowIsInAttention;

    int m_childrenLength;
    unsigned int m_maximumLength;

    QPointer<Plasma::Containment> m_containment;
    QRect m_maskArea;
    QScreen *m_screen;
    QList<PlasmaQuick::AppletQuickItem *> m_appletItems;
    QTimer m_initTimer;
    QTimer m_updateStateTimer;
    QWeakPointer<QMenu> m_contextMenu;

    Qt::Orientations m_panelOrientation;

    Plasma::Types::Location m_location;

    PanelVisibility m_panelVisibility;

    AbstractInterface *m_interface;

    void addAppletActions(QMenu *desktopMenu, Plasma::Applet *applet, QEvent *event);
    void addContainmentActions(QMenu *desktopMenu, QEvent *event);
    void setPanelOrientation(Plasma::Types::Location location);
    void updateMaximumLength();
};

} //NowDock namespace

#endif
