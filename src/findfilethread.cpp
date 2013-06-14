/*
 * findfilethread.cpp
 *
 *  Created on: Jun 11, 2013
 *      Author: fvacek
 */

#include "findfilethread.h"
#include "findfile.h"

#include <QStringBuilder>
#include <QDebug>

FindFileThread::FindFileThread(QObject *parent)
:QThread(parent), m_breakSearch(true)
{
}

FindFileThread::~FindFileThread() {
	// TODO Auto-generated destructor stub
}

void FindFileThread::startSearch(const QString &parent_path, const QString& search_string)
{
	m_searchRootPath = parent_path;
	m_searchString = search_string;
	start(QThread::LowPriority);
}

void FindFileThread::searchDir(const QString& parent_path, const QString& search_string)
{
	if(m_breakSearch) return;
	QList<FindFile::FileInfo> filst = FindFile::getDirContent(parent_path);
	foreach(const FindFile::FileInfo &fi, filst) {
		if(m_breakSearch) break;
		if(fi.name.contains(search_string, Qt::CaseInsensitive)) {
			emit fileFound(fi.toVariant());
		}
		if(fi.type == "dir") searchDir(fi.path, search_string);
	}
}

void FindFileThread::run()
{
	m_breakSearch = false;
	searchDir(m_searchRootPath, m_searchString);
}

void FindFileThread::stopAndDelete()
{
	if(isRunning()) {
		m_breakSearch = true;
		wait();
	}
	delete this;
}


