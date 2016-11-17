#include "nowdockplugin.h"
#include "panelwindow.h"

#include <qqml.h>

void NowDockPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.nowdock"));
    qmlRegisterType<PanelWindow>(uri, 0, 1, "PanelWindow");
}

