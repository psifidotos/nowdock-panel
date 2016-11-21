#ifndef PANELWINDOW_H
#define PANELWINDOW_H

#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <QWindow>

#include <plasma/plasma.h>

namespace NowDock
{

class PanelWindow : public QQuickWindow {
    Q_OBJECT
    Q_ENUMS(PanelVisibility)

    /**
     * the window mask, can be used in real transparent panels that set only the visual area
     * of the window
     * @since 5.8
     */
    Q_PROPERTY(QRect maskArea READ maskArea WRITE setMaskArea NOTIFY maskAreaChanged)

    Q_PROPERTY(Plasma::Types::Location location READ location WRITE setLocation NOTIFY locationChanged)

    Q_PROPERTY(PanelVisibility panelVisibility READ panelVisibility WRITE setPanelVisibility NOTIFY panelVisibilityChanged)

public:
    enum PanelVisibility {
        BelowActive = 0, /** always visible except if ovelaps with the active window, no area reserved */
        BelowFullscreen, /** always visible except if ovelaps with a fullscreen window, no area reserved */
        LetWindowsCover, /** always visible, windows will go over the panel, no area reserved */
        WindowsGoBelow, /** default, always visible, windows will go under the panel, no area reserved */
        AutoHide, /** the panel will be shownn only if the mouse cursor is on screen edges */
        AlwaysVisible,  /** always visible panel, "Normal" plasma panel, accompanies plasma's "Always Visible"  */
    };

    explicit PanelWindow(QQuickWindow *parent = Q_NULLPTR);
    ~PanelWindow();

    QRect maskArea() const;
    void setMaskArea(QRect area);

    Plasma::Types::Location location() const;
    void setLocation(Plasma::Types::Location location);

    PanelVisibility panelVisibility() const;
    void setPanelVisibility(PanelVisibility state);

Q_SIGNALS:
    void locationChanged();
    void maskAreaChanged();
    void panelVisibilityChanged();

public slots:
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void showOnTop();
    Q_INVOKABLE void shrinkTransient();


protected:
    void showEvent(QShowEvent *event) override;
    bool event(QEvent *e) override;
  //  void mouseMoveEvent(QMouseEvent *ev);

private Q_SLOTS:
    void activeWindowChanged(WId win);
    void hide();
    void initWindow();
    void updateVisibilityFlags();
    void updateWindowPosition();

private:
    //second pass of the initialization
    bool m_secondInitPass;

    QRect m_maskArea;
    QTimer m_hideTimer;
    QTimer m_initTimer;

    Plasma::Types::Location m_location;

    PanelVisibility m_panelVisibility;
};

} //NowDock namespace

#endif
