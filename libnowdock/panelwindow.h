#ifndef PANELWINDOW_H
#define PANELWINDOW_H

#include <QQuickItem>
#include <QQuickWindow>
#include <QWindow>


class PanelWindow : public QQuickWindow {
    Q_OBJECT

    /**
     * the window mask, can be used in real transparent panels that set only the visual area
     * of the window
     * @since 5.8
     */
    Q_PROPERTY(QRect maskArea READ maskArea WRITE setMaskArea NOTIFY maskAreaChanged)

public:
    explicit PanelWindow(QQuickWindow *parent = Q_NULLPTR);
    ~PanelWindow();

    QRect maskArea() const;
    void setMaskArea(QRect area);

Q_SIGNALS:
    void maskAreaChanged();

protected:
    void showEvent(QShowEvent *event) override;

private:
    QRect m_maskArea;

};

#endif
