
#include "applicationui.h"
#include "theapp.h"
#include "settings.h"

#include <QCoreApplication>
#include <QFile>
#include <QDebug>

#include <Qt/qdeclarativedebug.h>

#include "mymsghandler.h"

//using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
	/*
	{
		QString working_dir = QDir::currentPath();
		QString log_file = working_dir + "/logs/log";
		// make copy of recent log with txt extension
		QString log_file2 = working_dir + "/tmp/log.txt";
		QFile::remove(log_file2);
		QFile::copy(log_file, log_file2);
	}
	*/
	QCoreApplication::setOrganizationName("BlackBerry");
	QCoreApplication::setOrganizationDomain("blackberry.com");
	QCoreApplication::setApplicationName("NoTagPlayer");

	Settings settings;
	if(settings.boolValue("settings/application/developerSettings/logDebugInfo", false)) {
        qInstallMsgHandler(myMsgHandler);
	}

	qDebug() << "==========================================================";
	qWarning() << "AAAAAAAAAAAA" << QDateTime::currentDateTime().toString(Qt::ISODate);
	qDebug() << "==========================================================";

	TheApp app(argc, argv, &settings);

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    new ApplicationUI(&app);

    // Enter the application main event loop.
    return TheApp::exec();
}
