/*
 * findfilethread.h
 *
 *  Created on: Jun 11, 2013
 *      Author: fvacek
 */

#ifndef FINDFILETHREAD_H_
#define FINDFILETHREAD_H_

#include <QThread>
#include <QVariantList>
#include <QStringList>

class FindFileThread: public QThread
{
	Q_OBJECT
public:
	FindFileThread(QObject *parent = NULL);
	virtual ~FindFileThread();
signals:
	void fileFound(const QVariant &file_info);
public slots:
	void startSearch(const QString &parent_path, const QString &search_string);
	void stopAndDelete();
protected:
	virtual void run();
private:
	void searchDir(const QString &root_path, const QString &search_string);
private:
	bool m_breakSearch;
	QString m_searchRootPath;
	QString m_searchString;
};

#endif /* FINDFILETHREAD_H_ */
