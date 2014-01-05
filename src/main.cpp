
#include "applicationui.h"
#include "theapp.h"
#include "settings.h"

#include <QCoreApplication>
#include <QFile>
#include <QDebug>

#include <Qt/qdeclarativedebug.h>

//#include "mymsghandler.h"

//using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
	QCoreApplication::setOrganizationName("BlackBerry");
	QCoreApplication::setOrganizationDomain("blackberry.com");
	QCoreApplication::setApplicationName("NoTagPlayer");

	Settings settings;
	/*
	if(settings.boolValue("settings/application/developerSettings/logDebugInfo", false)) {
        qInstallMsgHandler(myMsgHandler);
	}
	*/
	qDebug() << "==========================================================";
	qDebug() << "NO_TAG_PLAYER" << QDateTime::currentDateTime().toString(Qt::ISODate);
	qDebug() << "==========================================================";

	TheApp app(argc, argv, &settings);

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    new ApplicationUI(&app);

    // Enter the application main event loop.
    return TheApp::exec();
}
