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

#include "nowdockcorona.h"
#include "nowdockview.h"
//#include "visibilitymanager.h"
#include "packageplugins/shell/nowdockpackage.h"

#include <QScreen>
#include <QDebug>
#include <KPluginMetaData>

#include <Plasma>
#include <Plasma/Corona>
#include <Plasma/Containment>
#include <KLocalizedString>
#include <KPackage/Package>
#include <KPackage/PackageLoader>

NowDockCorona::NowDockCorona(QObject *parent)
    : Plasma::Corona(parent)
{
    KPackage::Package package(new NowDockPackage(this));
    
    if (!package.isValid()) {
        qWarning() << staticMetaObject.className()
                   << "the package" << package.metadata().rawData() << "is invalid!";
        return;
    } else {
        qDebug() << staticMetaObject.className()
                 << "the package" << package.metadata().rawData() << "is valid!";
    }
    
    setKPackage(package);
    qmlRegisterTypes();
    connect(this, &Corona::containmentAdded, this, &NowDockCorona::addDock);
   // loadDefaultLayout();
    loadLayout();
}

NowDockCorona::~NowDockCorona()
{
    for (auto c : m_containments)
        c->deleteLater();
        
    qDebug() << "deleted" << this;
}

int NowDockCorona::numScreens() const
{
    return qGuiApp->screens().count();
}

QRect NowDockCorona::screenGeometry(int id) const
{
    const auto screens = qGuiApp->screens();
    
    if (id >= 0 && id < screens.count()) {
        return screens[id]->geometry();
    }
    
    return qGuiApp->primaryScreen()->geometry();
}

QRegion NowDockCorona::availableScreenRegion(int id) const
{
    const auto screens = qGuiApp->screens();
    
    if (id >= 0 && id < screens.count()) {
        return screens[id]->geometry();
    }
    
    return qGuiApp->primaryScreen()->availableGeometry();
}

QRect NowDockCorona::availableScreenRect(int id) const
{
    const auto screens = qGuiApp->screens();
    
    if (id >= 0 && id < screens.count()) {
        return screens[id]->availableGeometry();
    }
    
    return qGuiApp->primaryScreen()->availableGeometry();
}

QList<Plasma::Types::Location> NowDockCorona::freeEdges(int screen) const
{
    using Plasma::Types;
    QList<Types::Location> edges{Types::TopEdge, Types::BottomEdge
                                 , Types::LeftEdge, Types::RightEdge};
                                 
    for (const NowDockView *cont : m_containments) {
        if (cont && cont->containment()->screen() == screen)
            edges.removeOne(cont->location());
    }
    
    return edges;
}

int NowDockCorona::screenForContainment(const Plasma::Containment *containment) const
{
    return 0;
    
    while (const auto *parentCont = qobject_cast<const Plasma::Applet *>(containment->parent())) {
        if (parentCont->isContainment())
            containment = qobject_cast<const Plasma::Containment *>(parentCont);
    }
    
    for (auto *view : m_containments) {
        if (view && view->containment() == containment)
            return containment->screen();
    }
    
    return -1;
}

void NowDockCorona::addDock(Plasma::Containment *containment)
{
    if (!containment || !containment->kPackage().isValid()) {
        qWarning() << "the requested containment plugin can not be located or loaded";
        return;
    }
    
    qWarning() << "Adding dock for container...";

    auto dockView = new NowDockView(this);
    dockView->init();
    dockView->setContainment(containment);
    dockView->show();
    //dockView->showNormal();
    
    m_containments.push_back(dockView);
}

void NowDockCorona::loadDefaultLayout()
{

    qDebug() << "loading default layout";
    //! Settting mutable for create a containment
    setImmutability(Plasma::Types::Mutable);
    
    QVariantList args;
    auto defaultContainment = createContainmentDelayed("org.kde.nowdock.containment", args);
    //auto defaultContainment = createContainmentDelayed("org.kde.panel", args);
    defaultContainment->setContainmentType(Plasma::Types::PanelContainment);
    defaultContainment->init();
    
    if (!defaultContainment || !defaultContainment->kPackage().isValid()) {
        qWarning() << "the requested containment plugin can not be located or loaded";
        return;
    }
    
    auto config = defaultContainment->config();
    
    config.writeEntry("dock", "initial");
   // config.writeEntry("alignment", (int)Dock::Center);
   //  config.deleteEntry("wallpaperplugin");
    
    defaultContainment->setLocation(Plasma::Types::LeftEdge);
    
    auto cfg = defaultContainment->config();
    defaultContainment->save(cfg);

    addDock(defaultContainment);

    defaultContainment->createApplet(QStringLiteral("org.kde.store.nowdock.plasmoid"));
    defaultContainment->createApplet(QStringLiteral("org.kde.plasma.analogclock"));
}

inline void NowDockCorona::qmlRegisterTypes() const
{
    /*constexpr auto uri = "audoban.shell.candil";
    constexpr auto vMajor = 2;
    constexpr auto vMinor = 0;
    
    qmlRegisterUncreatableType<Candil::Dock>(uri, vMajor, vMinor, "Dock", "class Dock uncreatable");
    qmlRegisterUncreatableType<Candil::VisibilityManager>(uri, vMajor, vMinor, "VisibilityManager", "class VisibilityManager uncreatable");
    qmlRegisterUncreatableType<Candil::DockView>(uri, vMajor, vMinor, "DockView", "class DockView uncreatable");*/
    qmlRegisterType<QScreen>();
}

