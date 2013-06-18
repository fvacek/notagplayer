/*
 * findfile.cpp
 *
 *  Created on: Jun 12, 2013
 *      Author: fvacek
 */

#include "findfile.h"
#include "findfilethread.h"

//#include <QFileInfo>
#include <QDir>
#include <QDirIterator>
#include <QStringBuilder>
#include <QDebug>

//#if 0
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
//#endif

FindFile::FindFile(QObject *parent)
: QObject(parent)
{
	m_findFileThread = NULL;
	#if 0
	{
		DIR *dp;
		struct dirent *ep;
		struct dirent_extra *exp;

		const char *path = "/accounts/1000/removable/sdcard/downloads/BelowZero2009";
		dp = opendir (path);
		if (dp != NULL) {
			if (dircntl(dp, D_SETFLAG, D_FLAG_STAT) == -1) {
				perror("dircntl error");
			}
			while ((ep = readdir(dp)) != 0) {
				//puts (ep->d_name);
				fprintf(stderr, "~~~~~~~~~%s\n", ep->d_name);
				for( exp = _DEXTRA_FIRST(ep); _DEXTRA_VALID(exp, ep); exp = _DEXTRA_NEXT(exp)) {
					struct stat *statbuff = NULL;
					switch(exp->d_type) {
						case _DTYPE_NONE  :
							fprintf(stderr, "\tnone\n");
							break;
						case _DTYPE_STAT  :
							fprintf(stderr, "\tstat\n");
							statbuff = &((dirent_extra_stat*)exp)->d_stat;
							break;
						case _DTYPE_LSTAT :
							fprintf(stderr, "\tlstat\n");
							statbuff = &((dirent_extra_stat*)exp)->d_stat;
							break;
						default:
							fprintf(stderr, "\tunknown\n");
							break;
					}
					if(statbuff) {
						if(S_ISDIR(statbuff->st_mode)) {
							fprintf(stderr, "\tDIR\n");
						}
						if(S_ISREG(statbuff->st_mode)) {
							fprintf(stderr, "\tFILE\n");
						}
						if(S_ISCHR(statbuff->st_mode)) {
							fprintf(stderr, "\tCHAR DEVICE\n");
						}
						if(S_ISBLK(statbuff->st_mode)) {
							fprintf(stderr, "\tBLOCK DEVICE\n");
						}
						if(S_ISFIFO(statbuff->st_mode)) {
							fprintf(stderr, "\tPIPE\n");
						}
						if(S_ISLNK(statbuff->st_mode)) {
							fprintf(stderr, "\tSYMLINK\n");
						}
						if(S_ISSOCK(statbuff->st_mode)) {
							fprintf(stderr, "\tSOCKET\n");
						}
					}
				}
			}
			(void) closedir(dp);
		}
		else perror ("Couldn't open the directory");
	}
	#endif
	#if 0
	{
		QString path = "/accounts/1000/removable/sdcard/downloads/BelowZero2009";
		QDirIterator it(path, QDirIterator::Subdirectories | QDirIterator::FollowSymlinks);
		while (it.hasNext()) {
			qDebug() << "***************" << it.next();
		}
	}
	#endif
}

FindFile::~FindFile() {
}

bool FindFile::dirExists(const QString &dir_path)
{
	//QDir dir("/"%dir_path.join("/"));
	QDir dir(dir_path);
	return dir.exists();
}

QList<FindFile::FileInfo> FindFile::getDirContent(const QString &parent_dir_path, const QStringList &file_filters)
{
	QList<FileInfo> ret;
	/// don't know why, but entryInfoList() returns some duplicates
	QSet<QString> names;
#if USE_QT_IMPL
	QDir parent_dir(parent_dir_path);
	//qDebug() << "ApplicationUI::getDirContent" << parent_dir.canonicalPath();
	//qDebug() << "file_filters:" << file_filters.join(",") << "dir exists:" << parent_dir.exists() << "count:" << parent_dir.count();
	QFileInfoList fi_lst;
	QDir::Filters filters = QDir::NoDotAndDotDot | QDir::AllDirs | QDir::Files | QDir::Readable;
	//if(file_filters.isEmpty()) fi_lst = parent_dir.entryInfoList(filters, QDir::DirsFirst);
	//else
	fi_lst = parent_dir.entryInfoList(file_filters, filters, QDir::DirsFirst);
	foreach(QFileInfo qfi, fi_lst) {
		QString name = qfi.fileName();
		if(names.contains(name)) {
			qDebug() << "--- ignoring duplicate entry:" << name;
			continue;
		}
		names << name;
		FileInfo fi;
		fi.name = name;
		fi.path = qfi.absoluteFilePath();
		fi.type = qfi.isDir()? "dir": "file";
		//qDebug() << "\t" << name << "->" << path;
		ret << fi;
	}
#else
	foreach(const FileInfo &fi, getDirContentPosix(parent_dir_path, file_filters)) {
		if(names.contains(fi.name)) {
			qDebug() << "--- ignoring duplicate entry:" << fi.name;
			continue;
		}
		names << fi.name;
		//qDebug() << "\t" << fi.name << "->" << fi.path;
		ret << fi;
	}
#endif
	//qDebug() << "ApplicationUI::getDirContent return" << ret.count() << "items";
	return ret;
}

/// workaround for 32bit readdir in Qt4 on device
QList<FindFile::FileInfo> FindFile::getDirContentPosix(const QString &parent_dir_path, const QStringList &file_filters)
{
	QList<FileInfo> ret;
	DIR *dp;
	struct dirent *ep;
	struct dirent_extra *exp;
	QByteArray path = QFile::encodeName(parent_dir_path);
	dp = opendir(path.constData());
	if (dp != NULL) {
		if (dircntl(dp, D_SETFLAG, D_FLAG_STAT) == -1) {
			qWarning("dircntl error");
		}
		else {
			QStringList file_filters_ends;
			foreach(QString s, file_filters) file_filters_ends << s.mid(1); // cut * from *.mp3
			while ((ep = readdir(dp)) != 0) {
				//fprintf(stderr, "~~~~~~~~~%s\n", ep->d_name);
				QByteArray ba(ep->d_name);
				FileInfo fi;
				fi.name = QFile::decodeName(ba);
				if(parent_dir_path.endsWith('/')) fi.path = parent_dir_path%fi.name;
				else fi.path = parent_dir_path%'/'%fi.name;
				for( exp = _DEXTRA_FIRST(ep); _DEXTRA_VALID(exp, ep); exp = _DEXTRA_NEXT(exp)) {
					struct stat *statbuff = NULL;
					switch(exp->d_type) {
						case _DTYPE_NONE  :
							//fprintf(stderr, "\tnone\n");
							break;
						case _DTYPE_STAT  :
							//fprintf(stderr, "\tstat\n");
							statbuff = &((dirent_extra_stat*)exp)->d_stat;
							break;
						case _DTYPE_LSTAT :
							//fprintf(stderr, "\tlstat\n");
							statbuff = &((dirent_extra_stat*)exp)->d_stat;
							break;
						default:
							//fprintf(stderr, "\tunknown\n");
							break;
					}
					if(statbuff) {
						if(S_ISDIR(statbuff->st_mode)) {
							//fprintf(stderr, "\tDIR\n");
							fi.type = "dir";
						}
						if(S_ISREG(statbuff->st_mode)) {
							//fprintf(stderr, "\tFILE\n");
							fi.type = "file";
						}
						if(S_ISCHR(statbuff->st_mode)) {
							//fprintf(stderr, "\tCHAR DEVICE\n");
						}
						if(S_ISBLK(statbuff->st_mode)) {
							fprintf(stderr, "\tBLOCK DEVICE\n");
						}
						if(S_ISFIFO(statbuff->st_mode)) {
							//fprintf(stderr, "\tPIPE\n");
						}
						if(S_ISLNK(statbuff->st_mode)) {
							//fprintf(stderr, "\tSYMLINK\n");
						}
						if(S_ISSOCK(statbuff->st_mode)) {
							//fprintf(stderr, "\tSOCKET\n");
						}
					}
				}
				if(fi.name == "." || fi.name == "..") continue;
				bool is_match = true;
				if(fi.type != "dir") {
					is_match = file_filters_ends.isEmpty();
					if(!is_match) {
						foreach(QString ff, file_filters_ends) {
							if(fi.name.endsWith(ff, Qt::CaseInsensitive)) {
								is_match = true;
								break;
							}
						}
					}
				}
				if(is_match) {
					//qDebug() << "###############" << fi.type << fi.path;
					ret << fi;
				}
			}
		}
		(void) closedir(dp);
	}
	else qDebug() << "Couldn't open the directory:" << parent_dir_path;
	qSort(ret);
	return ret;
}

void FindFile::search(const QString &parent_path, const QString &search_string)
{
	if(m_findFileThread) {
		m_findFileThread->stopAndDelete();
	}
	m_findFileThread = new FindFileThread(this);
	connect(m_findFileThread, SIGNAL(fileFound(QVariant)), this, SIGNAL(fileFound(QVariant)), Qt::QueuedConnection);
	m_findFileThread->startSearch(parent_path, search_string);
}
