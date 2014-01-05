/*
 * logcollector.cpp
 *
 *  Created on: Jan 5, 2014
 *      Author: fvacek
 */

#include "logcollector.h"

#include <QByteArray>

LogCollector::LogCollector(QObject *parent)
: QProcess(parent)
{
	// TODO Auto-generated constructor stub

}

LogCollector::~LogCollector()
{
	// TODO Auto-generated destructor stub
}

QByteArray LogCollector::collectLog()
{
	QByteArray ret;
	do {
		start("slog2info", QStringList());
		if (!waitForStarted())
			break;

		//gzip.write("Qt rocks!");
		//gzip.closeWriteChannel();

		if (!waitForFinished())
			break;

		ret = readAll();
	} while(false);
	return ret;
}
