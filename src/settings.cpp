/*
 * settings.cpp
 *
 *  Created on: May 19, 2013
 *      Author: fvacek
 */

#include "settings.h"

#include <QDebug>

Settings::Settings(QObject *parent)
: QSettings(parent)
{
	// TODO Auto-generated constructor stub

}

Settings::~Settings() {
	// TODO Auto-generated destructor stub
}

QVariant Settings::value(const QString &key, const QVariant &default_value) const
{
	QVariant ret = Super::value(key, default_value);
	return ret;
}

void Settings::setValue(const QString &key, const QVariant &value)
{
	Super::setValue(key, value);
}

void Settings::dispose()
{
	deleteLater();
}
