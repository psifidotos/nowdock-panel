#ifndef PANELWINDOW_H
#define PANELWINDOW_H

#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <QWindow>

#include <KWindowInfo>

#include <plasma/plasma.h>

namespace NowDock
{

class PanelWindow : public QQuickWindow {
    Q_OBJECT
    Q_ENUMS(PanelVisibility)
    Q_ENUMS(Alignment)

    Q_PROPERTY(bool isAutoHidden READ isAutoHidden WRITE setIsAutoHidden NOTIFY isAutoHiddenChanged)

    Q_PROPERTY(bool isHovered READ isHovered NOTIFY isHoveredChanged)

    Q_PROPERTY(bool windowInAttention READ windowInAttention WRITE setWindowInAttention NOTIFY windowInAttentionChanged)

    Q_PROPERTY(int childrenLength READ childrenLength WRITE setChildrenLength NOTIFY childrenLengthChanged)

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

    bool isAutoHidden() const;
    void setIsAutoHidden(bool state);

    bool isHovered() const;

    bool windowInAttention() const;
    void setWindowInAttention(bool state);

    int childrenLength() const;
    void setChildrenLength(int value);

    QRect maskArea() const;
    void setMaskArea(QRect area);

    QRect screenGeometry() const;

    Plasma::Types::Location location() const;
    void setLocation(Plasma::Types::Location location);

    PanelVisibility panelVisibility() const;
    void setPanelVisibility(PanelVisibility state);

Q_SIGNALS:
    void childrenLengthChanged();
    void isAutoHiddenChanged();
    void isHoveredChanged();
    void locationChanged();
    void maskAreaChanged();
    void mustBeRaised(); //are used to triger the sliding animations from the qml part
    void mustBeLowered();
    void panelVisibilityChanged();
    void screenGeometryChanged();
    void windowInAttentionChanged();

public slots:
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void showNormal();
    Q_INVOKABLE void showOnTop();
    Q_INVOKABLE void showOnBottom();
    Q_INVOKABLE void shrinkTransient();


protected:
    void showEvent(QShowEvent *event) override;
    bool event(QEvent *e) override;
  //  void mouseMoveEvent(QMouseEvent *ev);

private Q_SLOTS:
    void activeWindowChanged(WId win);
    void updateState();
    void initWindow();
    void setIsHovered(bool state);
    void screenChanged(QScreen *screen);
    void updateVisibilityFlags();
    void updateWindowPosition();
    void windowChanged (WId id, NET::Properties properties, NET::Properties2 properties2);
    void windowRemoved (WId id);

private:
    bool m_isAutoHidden;
    bool m_isHovered;
    //second pass of the initialization
    bool m_secondInitPass;
    bool m_windowIsInAttention;

    int m_childrenLength;

    QRect m_maskArea;
    QScreen *m_screen;
    QTimer m_initTimer;
    QTimer m_updateStateTimer;

    Plasma::Types::Location m_location;

    WId m_activeWindow;
    WId m_demandsAttention;

    PanelVisibility m_panelVisibility;

    bool activeWindowAboveDock();
    bool dockIsCovered();
    bool dockIsCovering();

    bool isDesktop(WId id);
    bool isMaximized(KWindowInfo *info);
    bool isNormal(KWindowInfo *info);
    bool isOnBottom(KWindowInfo *info);
    bool isOnTop(KWindowInfo *info);
};

} //NowDock namespace

#endif
