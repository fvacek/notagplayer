/*
 * logcollector.h
 *
 *  Created on: Jan 5, 2014
 *      Author: fvacek
 */

#ifndef LOGCOLLECTOR_H_
#define LOGCOLLECTOR_H_

#include <QProcess>

class QByteArray;

class LogCollector: public QProcess
{
	Q_OBJECT
public:
	LogCollector(QObject *parent = NULL);
	virtual ~LogCollector();
public:
	QByteArray collectLog();
};

#endif /* LOGCOLLECTOR_H_ */
