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

bool Settings::boolValue(const QString &key, bool default_val) const
{
	bool ret = default_val;
	QVariant v = value(key);
	if(v.isValid()) ret = v.toBool();
	return ret;
}

void Settings::setValue(const QString &key, const QVariant &value)
{
	Super::setValue(key, value);
}

