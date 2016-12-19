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

#include "nowdockview.h"
//#include "visibilitymanager.h"
//#include "dockconfigview.h"

#include <QQmlContext>
#include <QQuickItem>
#include <QMetaEnum>
//#include <QtX11Extras/QX11Info>

#include <NETWM>
#include <KWindowSystem>
#include <Plasma/Containment>
#include <KActionCollection>

#include "nowdockcorona.h"
//using Candil::Dock;

NowDockView::NowDockView(Plasma::Corona *corona, QScreen *targetScreen)
    : PlasmaQuick::ContainmentView(corona),
      m_corona(corona)
{
    setTitle(corona->kPackage().metadata().name());
    setIcon(QIcon::fromTheme(corona->kPackage().metadata().iconName()));

    setResizeMode(QuickViewSharedEngine::SizeRootObjectToView);
    setClearBeforeRendering(true);
    setFlags(Qt::FramelessWindowHint
             | Qt::WindowStaysOnTopHint
             | Qt::NoDropShadowWindowHint
             | Qt::WindowDoesNotAcceptFocus);
             
//    NETWinInfo winfo(QX11Info::connection(), winId(), winId(), 0, 0);
 //   winfo.setAllowedActions(NET::ActionChangeDesktop);
    
    if (targetScreen)
        adaptToScreen(targetScreen);
    else
        adaptToScreen(qGuiApp->primaryScreen());
        
    m_timerGeometry.setSingleShot(true);
    m_timerGeometry.setInterval(100);

    setThickness(100);
    
 /*   connect(this, &NowDockView::containmentChanged
    , this, [&]() {
        if (!containment())
            return;
            
        if (!m_visibility) {
            m_visibility = new VisibilityManager(containment());
            m_visibility->setWinId(winId());
            connect(m_visibility.data(), &VisibilityManager::visibilityChanged
                    , this, &DockView::visibilityChanged);
                    
        }
        
        m_visibility->setContainment(containment());
        auto config = containment()->config();
        const int alignment = config.readEntry("alignment", (int)(Dock::Center));
        setAlignment(static_cast<Dock::Alignment>(alignment));
        
    }, Qt::DirectConnection);*/
    
    
}

NowDockView::~NowDockView()
{
}

void NowDockView::init()
{
 /*   connect(this, &NowDockView::screenChanged
            , this, &NowDockView::adaptToScreen
            , Qt::QueuedConnection);
            
    connect(&m_timerGeometry, &QTimer::timeout, [&]() {
        updateDockPosition();
        resizeWindow();
        updateDockGeometry();
    });
    
    connect(this, &NowDockView::locationChanged, [&]() {
        //! avoid glitches
        setMask(geometry());
        m_timerGeometry.start();
    });
    */
  /*  connect(this, &DockView::alignmentChanged , [&]() {
        //! avoid glitches
        //setMask(geometry());
        m_timerGeometry.start();
    });*/
    
    connect(KWindowSystem::self(), &KWindowSystem::compositingChanged
    , this, [&]() {
        updateDockGeometry();
        emit compositingChanged();
    }
    , Qt::QueuedConnection);
    
    connect(this, &NowDockView::screenGeometryChanged
            , this, &NowDockView::updateDockGeometry
            , Qt::QueuedConnection);
            
    //Plasma::Theme *theme = new Plasma::Theme(this);
    //theme->setUseGlobalSettings(false);
    //theme->setThemeName("air");

    rootContext()->setContextProperty(QStringLiteral("panel"), this);
    setSource(corona()->kPackage().filePath("nowdockui"));
    qDebug() << "SOURCE:" << source();

    updateDockPosition();
}

//!BEGIN SLOTS
void NowDockView::adaptToScreen(QScreen *screen)
{
    setScreen(screen);
    
    if (formFactor() == Plasma::Types::Vertical)
        m_maxLength = screen->size().height();
    else
        m_maxLength = screen->size().width();
        
    KWindowSystem::setOnAllDesktops(winId(), true);
    KWindowSystem::setType(winId(), NET::Dock);
    
    if (containment())
        containment()->reactToScreenChange();
        
    m_timerGeometry.start();
}

QQmlListProperty<QScreen> NowDockView::screens()
{
    return QQmlListProperty<QScreen>(this, nullptr, &countScreens, &atScreens);
}

int NowDockView::countScreens(QQmlListProperty<QScreen> *property)
{
    Q_UNUSED(property)
    return qGuiApp->screens().count();
}

QScreen *NowDockView::atScreens(QQmlListProperty<QScreen> *property, int index)
{
    Q_UNUSED(property)
    return qGuiApp->screens().at(index);
}

void NowDockView::showConfigurationInterface(Plasma::Applet *applet)
{
 /*   if (!applet || !applet->containment())
        return;
        
    Plasma::Containment *c = qobject_cast<Plasma::Containment *>(applet);
    
    if (m_configView && c && c->isContainment() && c == containment()) {
        if (m_configView->isVisible()) {
            m_configView->hide();
        } else {
            m_configView->show();
            m_configView->requestActivate();
        }
        
        return;
    } else if (m_configView) {
        if (m_configView->applet() == applet) {
            m_configView->show();
            m_configView->requestActivate();
            return;
        } else {
            m_configView->hide();
            m_configView->deleteLater();
        }
    }
    
    if (c && containment() && c->isContainment() && c->id() == containment()->id()) {
        m_configView = new DockConfigView(c, this);
    } else {
        m_configView = new PlasmaQuick::ConfigView(applet);
    }
    
    m_configView->init();
    m_configView->show();
    m_configView->requestActivate();*/
}

void NowDockView::resizeWindow()
{
    setVisible(true);

    QSize screenSize = screen()->size();
    
    /*if (formFactor() == Plasma::Types::Vertical) {
        const QSize size{maxThickness(), screenSize.height()};
        setMinimumSize(size);
        setMaximumSize(size);
        resize(size);
    } else {
        const QSize size{screenSize.width(), maxThickness()};
        setMinimumSize(size);
        setMaximumSize(size);
        resize(size);
    }*/
    const QSize size{140, screenSize.height()};
    setMinimumSize(size);
    setMaximumSize(size);
    resize(size);
    
    qDebug() << "shell size:" << size;
}

void NowDockView::updateDockGeometry()
{
    if (!containment())
        return;
        
    if (!containment()->isUserConfiguring())
        updateOffset();
        
    const QRect screenGeometry = screen()->geometry();
    // topLeft or x/y position
    QPoint position;
    
    int length = m_length;
    //length = screenGeometry.width();
    length = 500;
    position = {0, 0};
    
    /*switch (location()) {
        case Plasma::Types::TopEdge:
            switch (m_alignment) {
                case Dock::Fill:
                    length = screenGeometry.width();
                    
                case Dock::Begin:
                    position = {screenGeometry.x(), screenGeometry.y()};
                    break;
                case Dock::Center:
                    position = {screenGeometry.center().x() - m_length / 2 + m_offset, screenGeometry.y()};
                    break;
                case Dock::End:
                    position = {screenGeometry.width() - m_length, screenGeometry.y()};
                    break;
            }
            
            break;
            
        case Plasma::Types::BottomEdge:
            switch (m_alignment) {
                case Dock::Fill:
                    length = screenGeometry.width();
                    
                case Dock::Begin:
                    position = {screenGeometry.x(), screenGeometry.height() - m_thickness};
                    break;
                case Dock::Center:
                    position = {screenGeometry.center().x() - m_length / 2 + m_offset, screenGeometry.height() - m_thickness};
                    break;
                case Dock::End:
                    position = {screenGeometry.width() - m_length, screenGeometry.height() - m_thickness};
                    break;
            }
            
            break;
            
        case Plasma::Types::LeftEdge:
            switch (m_alignment) {
                case Dock::Fill:
                    length = screenGeometry.height();
                    
                case Dock::Begin:
                    position = {screenGeometry.x(), screenGeometry.y()};
                    break;
                case Dock::Center:
                    position = {screenGeometry.x(), screenGeometry.center().y() - m_length / 2 + m_offset};
                    break;
                case Dock::End:
                    position = {screenGeometry.x(), screenGeometry.height() - m_length};
                    break;
            }
            
            break;
            
        case Plasma::Types::RightEdge:
            switch (m_alignment) {
                case Dock::Fill:
                    length = screenGeometry.height();
                    
                case Dock::Begin:
                    position = {screenGeometry.width() - m_thickness, screenGeometry.y()};
                    break;
                case Dock::Center:
                    position = {screenGeometry.width() - m_thickness, screenGeometry.center().y() - m_length / 2 + m_offset};
                    break;
                case Dock::End:
                    position = {screenGeometry.width() - m_thickness, screenGeometry.height() - m_length};
                    break;
            }
            
            break;
            
        default:
            qWarning() << "wrong location:" << qEnumToStr(containment()->location());
    }*/
    
    m_dockGeometry.setTopLeft(position);
    
    if (containment()->formFactor() == Plasma::Types::Vertical)
        m_dockGeometry.setSize({m_thickness, length});
    else
        m_dockGeometry.setSize({length, m_thickness});
        
    qDebug() << "updating dock rect:" << m_dockGeometry;
    
    updateDockPosition();
    resizeWindow();

    //  m_visibility->updateDockRect(m_dockGeometry);
}

inline void NowDockView::updateDockPosition()
{
    if (!containment())
        return;
        
    const QRect screenGeometry = screen()->geometry();
    QPoint position;
    
    containment()->setFormFactor(Plasma::Types::Horizontal);
    //position = {screenGeometry.x(), screenGeometry.height() - maxThickness()};
    position = {0, 0};
    m_maxLength = screenGeometry.width();

/*    switch (location()) {
        case Plasma::Types::TopEdge:
            containment()->setFormFactor(Plasma::Types::Horizontal);
            position = {screenGeometry.x(), screenGeometry.y()};
            m_maxLength = screenGeometry.width();
            break;
            
        case Plasma::Types::BottomEdge:
            containment()->setFormFactor(Plasma::Types::Horizontal);
            position = {screenGeometry.x(), screenGeometry.height() - maxThickness()};
            m_maxLength = screenGeometry.width();
            break;
            
        case Plasma::Types::RightEdge:
            containment()->setFormFactor(Plasma::Types::Vertical);
            position = {screenGeometry.width() - maxThickness(), screenGeometry.y()};
            m_maxLength = screenGeometry.height();
            break;
            
        case Plasma::Types::LeftEdge:
            containment()->setFormFactor(Plasma::Types::Vertical);
            position = {screenGeometry.x(), screenGeometry.y()};
            m_maxLength = screenGeometry.height();
            break;
            
        default:
            qWarning() << "wrong location, couldn't update the panel position"
                       << location();
    }*/
    
    emit maxLengthChanged();
    setPosition(position);
    qDebug() << "shell position:" << position;
}

QRect NowDockView::dockMask() const
{
    if (mask().rectCount() >= 1)
        return mask().rects()[0];
        
    return QRect();
}

void NowDockView::setDockMask(QRect mask)
{
    qDebug() << "setting dock mask:" << mask;
    
    setMask(mask);
    emit maskChanged();
}

int NowDockView::maxThickness() const
{
    // the thickness per space reserved for animations
    int thickness = std::min(m_thickness, m_length);
    
    if (KWindowSystem::compositingActive())
        return thickness * 1.6;
        
    return thickness;
}

bool NowDockView::compositing() const
{
    return KWindowSystem::compositingActive();
}

/*Candil::VisibilityManager *NowDockView::visibility()
{
    return  m_visibility.data();
}*/

int NowDockView::thickness() const
{
    return m_thickness;
}

void NowDockView::setThickness(int thickness)
{
    if (m_thickness == thickness)
        return;
        
    m_thickness = thickness;
    m_timerGeometry.start();
    emit thicknessChanged();
}

int NowDockView::length() const
{
    return m_length;
}

void NowDockView::setLength(int length)
{
    if (m_length == length)
        return;
        
    if (length > m_maxLength)
        m_length = m_maxLength;
    else
        m_length = length;
        
    m_timerGeometry.start();
    emit lengthChanged();
}

int NowDockView::maxLength() const
{
    return m_maxLength;
}

void NowDockView::setMaxLength(int maxLength)
{
    if (m_maxLength == maxLength)
        return;
        
    m_maxLength = maxLength;
    emit maxLengthChanged();
}

/*Dock::Alignment NowDockView::alignment() const
{
    return m_alignment;
}

void NowDockView::setAlignment(Dock::Alignment align)
{
    if (m_alignment == align)
        return;
        
    m_alignment = align;
    emit alignmentChanged();
}
*/
int NowDockView::offset() const
{
    return m_offset;
}

void NowDockView::setOffset(int offset)
{
    if (m_offset == offset)
        return;
        
    m_offset = offset;
    m_timerGeometry.start();
    emit offsetChanged();
}

void NowDockView::updateOffset()
{
    if (!containment())
        return;
        
    const float offsetPercent = containment()->config().readEntry("offset").toFloat();
    const int offset = offsetPercent * (m_maxLength - m_length) / 2;
    
    if (offset == m_offset)
        return;
        
    m_offset = offset;
    emit offsetChanged();
}


bool NowDockView::event(QEvent *e)
{
   /* if (edgeActivated()) {
        if (e->type() == QEvent::Enter) {
            m_unhideTimer.stop();
        } else if (e->type() == QEvent::Leave) {
            m_unhideTimer.start();
        }
    }*/

    /*Fitt's law: if the containment has margins, and the mouse cursor clicked
     * on the mouse edge, forward the click in the containment boundaries
     */
    switch (e->type()) {
        //case QEvent::MouseMove:
        case QEvent::MouseButtonPress: {
        containment()->updateConstraints(Plasma::Types::ImmutableConstraint);
        m_corona->setImmutability(Plasma::Types::UserImmutable);

        /*if (m_corona->immutability() == Plasma::Types::Mutable) {
            qDebug() << "immutable";
            containment()->setUserConfiguring(false);
            //an action is needed to unlock lock widgets

        } else {
            qDebug() << "mutable";
            containment()->setUserConfiguring(true);
        }*/


            QMouseEvent *me = static_cast<QMouseEvent *>(e);

            //first, don't mess with position if the cursor is actually outside the view:
            //somebody is doing a click and drag that must not break when the cursor i outside
            if (geometry().contains(QCursor::pos(screen()))) {
                if (!containmentContainsPosition(me->windowPos())) {
                    auto me2 = new QMouseEvent(me->type(),
                                    positionAdjustedForContainment(me->windowPos()),
                                    positionAdjustedForContainment(me->windowPos()),
                                    positionAdjustedForContainment(me->windowPos()) + position(),
                                    me->button(), me->buttons(), me->modifiers());

                    QCoreApplication::postEvent(this, me2);
                    return true;
                }
            } else {
                // discard event if current mouse position is outside the panel
                return true;
            }
            break;
        }
        default:
            break;
    }

   /*     case QEvent::Enter:
        case QEvent::Leave:
            // QtQuick < 5.6 issue:
            // QEvent::Leave is triggered on MouseButtonPress Qt::LeftButton
            break;

        case QEvent::Wheel: {
            QWheelEvent *we = static_cast<QWheelEvent *>(e);

            if (!containmentContainsPosition(we->pos())) {
                auto we2 = new QWheelEvent(positionAdjustedForContainment(we->pos()),
                                positionAdjustedForContainment(we->pos()) + position(),
                                we->pixelDelta(), we->angleDelta(), we->delta(),
                                we->orientation(), we->buttons(), we->modifiers(), we->phase());

                QCoreApplication::postEvent(this, we2);
                return true;
            }
            break;
        }

        case QEvent::DragEnter: {
            QDragEnterEvent *de = static_cast<QDragEnterEvent *>(e);
            if (!containmentContainsPosition(de->pos())) {
                auto de2 = new QDragEnterEvent(positionAdjustedForContainment(de->pos()).toPoint(),
                                    de->possibleActions(), de->mimeData(), de->mouseButtons(), de->keyboardModifiers());

                QCoreApplication::postEvent(this, de2);
                return true;
            }
            break;
        }
        //DragLeave just works
        case QEvent::DragLeave:
            break;
        case QEvent::DragMove: {
            QDragMoveEvent *de = static_cast<QDragMoveEvent *>(e);
            if (!containmentContainsPosition(de->pos())) {
                auto de2 = new QDragMoveEvent(positionAdjustedForContainment(de->pos()).toPoint(),
                                   de->possibleActions(), de->mimeData(), de->mouseButtons(), de->keyboardModifiers());

                QCoreApplication::postEvent(this, de2);
                return true;
            }
            break;
        }
        case QEvent::Drop: {
            QDropEvent *de = static_cast<QDropEvent *>(e);
            if (!containmentContainsPosition(de->pos())) {
                auto de2 = new QDropEvent(positionAdjustedForContainment(de->pos()).toPoint(),
                               de->possibleActions(), de->mimeData(), de->mouseButtons(), de->keyboardModifiers());

                QCoreApplication::postEvent(this, de2);
                return true;
            }
            break;
        }

        case QEvent::Hide: {
            if (m_panelConfigView && m_panelConfigView.data()->isVisible()) {
                m_panelConfigView.data()->hide();
            }
            break;
        }
        case QEvent::PlatformSurface:
            if (auto pe = dynamic_cast<QPlatformSurfaceEvent*>(e)) {
                switch (pe->surfaceEventType()) {
                case QPlatformSurfaceEvent::SurfaceCreated:
                    setupWaylandIntegration();
                    PanelShadows::self()->addWindow(this, enabledBorders());
                    break;
                case QPlatformSurfaceEvent::SurfaceAboutToBeDestroyed:
                    delete m_shellSurface;
                    m_shellSurface = nullptr;
                    PanelShadows::self()->removeWindow(this);
                    break;
                }
            }
            break;
        default:
            break;
    }*/

    return ContainmentView::event(e);
}

bool NowDockView::containmentContainsPosition(const QPointF &point) const
{
    QQuickItem *containmentItem = containment()->property("_plasma_graphicObject").value<QQuickItem *>();

    if (!containmentItem) {
        return false;
    }

    return QRectF(containmentItem->mapToScene(QPoint(0,0)), QSizeF(containmentItem->width(), containmentItem->height())).contains(point);
}

QPointF NowDockView::positionAdjustedForContainment(const QPointF &point) const
{
    QQuickItem *containmentItem = containment()->property("_plasma_graphicObject").value<QQuickItem *>();

    if (!containmentItem) {
        return point;
    }

    QRectF containmentRect(containmentItem->mapToScene(QPoint(0,0)), QSizeF(containmentItem->width(), containmentItem->height()));

    return QPointF(qBound(containmentRect.left() + 2, point.x(), containmentRect.right() - 2),
                   qBound(containmentRect.top() + 2, point.y(), containmentRect.bottom() - 2));
}


//!END SLOTS


//!END namespace
