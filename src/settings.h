/*
 * settings.h
 *
 *  Created on: May 19, 2013
 *      Author: fvacek
 */

#ifndef SETTINGS_H_
#define SETTINGS_H_

#include <QSettings>
#include <QStringList>

class Settings : public QSettings
{
	Q_OBJECT
private:
	typedef QSettings Super;
public:
	Settings(QObject *parent = NULL);
	virtual ~Settings();
public slots:
	void beginGroup(const QString &prefix) {return Super::beginGroup(prefix);}
	void endGroup() {Super::endGroup();}
	void setValue(const QString &key, const QVariant &value);
	QVariant value(const QString &key, const QVariant &default_value = QVariant()) const;
	QStringList childGroups() const {return Super::childGroups();}
	void remove(const QString &key) {Super::remove(key);}
};

#endif /* SETTINGS_H_ */
