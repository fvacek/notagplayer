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

#include <dirent.h>
#if 0
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#if !defined __EXT_QNX__READDIR_R
    #warning "dirent.h should be included to following test work"
#endif

#if defined __EXT_QNX__READDIR64_R && !defined QT_NO_READDIR64
    #warning "QNX readdir64_r defined and supported by current QT version"
	#define USE_QT_IMPL
	//#warning "QT DirIterator implementation is disabled even if system supports it"
#else
    #if defined __EXT_QNX__READDIR64_R  /// defined in dirent.h
        #warning "QNX readdir64_r defined but NOT supported by current QT version"
    #else
        #warning "QNX readdir64_r NOT supported by current QNX libraries"
    #endif
#endif

const QLatin1String FindFile::FileInfo::TypeDir = QLatin1String("dir");
const QLatin1String FindFile::FileInfo::TypeFile = QLatin1String("file");

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
	bool ret = dir.exists();
	qDebug() << Q_FUNC_INFO << dir_path << "return:" << ret;
	return ret;
}

#ifndef USE_QT_IMPL
/// workaround for 32bit readdir in Qt4 on device
static QList<FindFile::FileInfo> getDirContentPosix(const QString &parent_dir_path, const QStringList &file_filters)
{
	QList<FindFile::FileInfo> ret;
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
				//qDebug() << "~~~~~~~~~" << ep->d_name;
				QByteArray ba(ep->d_name);
				FindFile::FileInfo fi;
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
							//qDebug() << "\tDIR";
							fi.type = FindFile::FileInfo::TypeDir;
						}
						if(S_ISREG(statbuff->st_mode)) {
							//qDebug() << "\tFILE";
							fi.type = FindFile::FileInfo::TypeFile;
						}
						if(S_ISCHR(statbuff->st_mode)) {
							//qDebug() << "\tCHAR DEVICE";
						}
						if(S_ISBLK(statbuff->st_mode)) {
							//qDebug() << "\tBLOCK DEVICE";
						}
						if(S_ISFIFO(statbuff->st_mode)) {
							//qDebug() << "\tPIPE\n";
						}
						if(S_ISLNK(statbuff->st_mode)) {
							//qDebug() << "\tSYMLINK";
						}
						if(S_ISSOCK(statbuff->st_mode)) {
							//qDebug() << "\tSOCKET";
						}
					}
				}
				if(fi.name == "." || fi.name == "..") continue;
				if(fi.type.isEmpty()) {
					// it is better to hide files with unknown type
					continue;
				}
				bool is_match = true;
				if(fi.type != FindFile::FileInfo::TypeDir) {
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
#endif

QList<FindFile::FileInfo> FindFile::getDirContent(const QString &parent_dir_path, const QStringList &file_ends_filter)
{
	qDebug() << "=======" << Q_FUNC_INFO << parent_dir_path << "filters:" << file_ends_filter.join(", ");
	QList<FileInfo> ret;
	/// don't know why, but entryInfoList() returns some duplicates
	QSet<QString> names;
#ifdef USE_QT_IMPL
	QDirIterator dit(parent_dir_path);
	while(dit.hasNext()) {
		dit.next();
		QFileInfo qfi = dit.fileInfo();
		QString name = qfi.fileName();
		if(names.contains(name)) {
			qDebug() << "--- ignoring duplicate entry:" << name;
			continue;
		}
		names << name;

		if(name == "." || name == "..")
		    continue;

		bool is_match = true;
        qDebug() << "###############" << name << "is file:" << qfi.isFile() << "is dir:" << qfi.isDir();
		if(qfi.isFile()) {
			is_match = file_ends_filter.isEmpty();
			if(!is_match) {
				foreach(QString ff, file_ends_filter) {
					if(name.endsWith(ff, Qt::CaseInsensitive)) {
						is_match = true;
						break;
					}
				}
			}
		}
		if(is_match) {
			FileInfo fi;
			fi.name = name;
			fi.path = qfi.absoluteFilePath();
			fi.type = qfi.isDir()? FileInfo::TypeDir: qfi.isFile()? FileInfo::TypeFile: QString();
			//qDebug() << "\t" << name << "->" << path;
			if(!fi.type.isEmpty()) {
				// it is better to hide files with unknown type
				ret << fi;
			}
		}
	}
	#if 0
	QDir parent_dir(parent_dir_path);
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
	#endif
#else
	foreach(const FileInfo &fi, getDirContentPosix(parent_dir_path, file_filters_ends)) {
		if(names.contains(fi.name)) {
			qDebug() << "--- ignoring duplicate entry:" << fi.name;
			continue;
		}
		names << fi.name;
		//qDebug() << "\t" << fi.toString();
		ret << fi;
	}
#endif
	//qDebug() << "ApplicationUI::getDirContent return" << ret.count() << "items";
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
