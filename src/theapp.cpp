/*
 * theapp.cpp
 *
 *  Created on: Jan 4, 2014
 *      Author: fvacek
 */

#include "theapp.h"

#include <QDir>

TheApp::TheApp(int &argc, char **argv, Settings *settings)
: bb::cascades::Application(argc, argv), m_settings(settings)
{
	// TODO Auto-generated constructor stub

}

TheApp::~TheApp()
{
	// TODO Auto-generated destructor stub
}

TheApp* theApp()
{
	TheApp *ret = qobject_cast<TheApp*>(bb::cascades::Application::instance());
	if(!ret) {
		qFatal("%s: Bad application instance.", Q_FUNC_INFO);
	}
	return ret;
}

Settings* TheApp::settings()
{
	return m_settings;
}

QString TheApp::logFilePath()
{
	return QDir::currentPath() + "/logs/log";
}
