/*
 * findfile.h
 *
 *  Created on: Jun 12, 2013
 *      Author: fvacek
 */

#ifndef FINDFILE_H_
#define FINDFILE_H_

#include <qobject.h>

#include <QVariantMap>
#include <QStringList>

class FindFileThread;

class FindFile: public QObject
{
	Q_OBJECT
public:
	struct FileInfo
	{
		QString name;
		QString path;
		QString type;

		//FileInfo() {}
		//FileInfo(const QString &n, const QString &p, const QString &t) : name(n), path(p), type(t) {}

		bool operator<(const FileInfo &other) const
		{
			if(type < other.type) return true;
			if(type == other.type) return (name < other.name);
			return false;
		}

		QVariantMap toVariant() const
		{
			QVariantMap m;
			m["name"] = name;
			m["path"] = path;
			m["type"] = type;
			return m;
		}
	};
public:
	FindFile(QObject *parent = NULL);
	virtual ~FindFile();
public:
    static bool dirExists(const QString &dir_path);
    static QList<FileInfo> getDirContent(const QString &parent_dir_path, const QStringList &file_filters = QStringList());
    static QList<FileInfo> getDirContentPosix(const QString &parent_dir_path, const QStringList &file_filters);
signals:
	void fileFound(const QVariant &file_info);
public slots:
	void search(const QString &parent_path, const QString &search_string);
private:
    FindFileThread *m_findFileThread;
};

#endif /* FINDFILE_H_ */
