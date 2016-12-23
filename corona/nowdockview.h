/*
 * Copyright 2014  Bhushan Shah <bhush94@gmail.com>
 * Copyright 2014 Marco Martin <notmart@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#ifndef NOWDOCKVIEW_H
#define NOWDOCKVIEW_H

#include <climits>

#include "plasmaquick/configview.h"
#include "plasmaquick/containmentview.h"
#include "visibilitymanager.h"

#include <QQuickView>
#include <QQmlListProperty>
#include <QScreen>
#include <QPointer>
#include <QTimer>

namespace Plasma {
class Types;
class Corona;
class Containment;
}

/*namespace Candil {
class Dock;
class DockView;
class DockConfigView;
class VisibilityManager;
}*/

class NowDockView : public PlasmaQuick::ContainmentView {
    Q_OBJECT
    
    Q_PROPERTY(VisibilityManager *visibility READ visibility NOTIFY visibilityChanged)
 //   Q_PROPERTY(Candil::Dock::Alignment alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
    Q_PROPERTY(int thickness READ thickness WRITE setThickness NOTIFY thicknessChanged)
    Q_PROPERTY(int length READ length WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(int maxLength READ maxLength WRITE setMaxLength NOTIFY maxLengthChanged)
    Q_PROPERTY(int offset READ offset WRITE setOffset NOTIFY offsetChanged)
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool compositing READ compositing NOTIFY compositingChanged)
    Q_PROPERTY(QRect maskArea READ maskArea WRITE setMaskArea NOTIFY maskAreaChanged)
    Q_PROPERTY(QQmlListProperty<QScreen> screens READ screens)
    
public:
    NowDockView(Plasma::Corona *corona, QScreen *targetScreen = nullptr);
    virtual ~NowDockView();
    
    void init();
    
   // Candil::VisibilityManager *visibility();
    
    int thickness() const;
    void setThickness(int thickness);

    int length() const;
    void setLength(int length);
    
    QRect maskArea() const;
    void setMaskArea(QRect area);

    int maxLength() const;
    void setMaxLength(int maxLength);
    
  //  Dock::Alignment alignment() const;
  //  void setAlignment(Dock::Alignment align);
    
    int offset() const;
    void setOffset(int offset);
    
    void updateOffset();
    
    VisibilityManager *visibility();

    void resizeWindow();
    void restoreConfig();
    void saveConfig();
    void updateDockPosition();
    void updateDockGeometry();
    int maxThickness() const;
    bool compositing() const;
    
    void adaptToScreen(QScreen *screen);
    
    QQmlListProperty<QScreen> screens();
    static int countScreens(QQmlListProperty<QScreen> *property);
    static QScreen *atScreens(QQmlListProperty<QScreen> *property, int index);
    
protected slots:
    void showConfigurationInterface(Plasma::Applet *applet) override;
    
protected:
    bool event(QEvent *ev) override;
//    void showEvent(QShowEvent *ev) override;
    
signals:
 //   void visibilityChanged();
    void alignmentChanged();
    void compositingChanged();
    void heightChanged();
    void lengthChanged();
    void maskAreaChanged();
    void maxLengthChanged();
    void offsetChanged();
    void thicknessChanged();
    void visibilityChanged();
    void widthChanged();
    
private:
    bool containmentContainsPosition(const QPointF &point) const;
    QPointF positionAdjustedForContainment(const QPointF &point) const;

    int m_offset{0};
    int m_thickness{0};
    int m_length{0};
    int m_maxLength{INT_MAX};
    
    QRect m_dockGeometry;
    QRect m_maskArea;
    QPointer<PlasmaQuick::ConfigView> m_configView;

    QTimer m_timerGeometry;
    Plasma::Theme *theme{nullptr};
    Plasma::Corona *m_corona;

    QPointer<VisibilityManager> m_visibility;
};

#endif
