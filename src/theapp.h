/*
 * theapp.h
 *
 *  Created on: Jan 4, 2014
 *      Author: fvacek
 */

#ifndef THEAPP_H_
#define THEAPP_H_

#include <bb/cascades/Application>

class Settings;

class TheApp: public bb::cascades::Application
{
	Q_OBJECT
public:
	TheApp(int &argc, char **argv, Settings *settings);
	virtual ~TheApp();
public:
    Settings* settings();
public slots:
	QString logFilePath();
private:
    Settings *m_settings;
};

TheApp* theApp();

#endif /* THEAPP_H_ */
