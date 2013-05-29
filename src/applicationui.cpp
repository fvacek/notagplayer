#include "applicationui.hpp"
#include "settings.h"
#include "cover.h"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/device/DisplayInfo>

#include <QFileInfo>
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

using namespace bb::cascades;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
QObject(app)
{
	m_settings = new Settings(this);
	// prepare the localization
	m_pTranslator = new QTranslator(this);
	m_pLocaleHandler = new LocaleHandler(this);
	QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
	// initial load
	onSystemLanguageChanged();

	Cover *cover = new Cover();
	Application::instance()->setCover(cover);

	// Create scene document from main.qml asset, the parent is set
	// to ensure the document gets destroyed properly at shut down.
	QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
	qml->setContextProperty("ApplicationUI", this);
	//qml->setContextProperty("CppCover", cover);

	// Create root object for the UI
	AbstractPane *root = qml->createRootObject<AbstractPane>();

	// Set created root object as the application scene
	app->setScene(root);
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

ApplicationUI::~ApplicationUI()
{
	qDebug() << "ApplicationUI::~ApplicationUI()";
	//emit aboutToQuit();
}

void ApplicationUI::onSystemLanguageChanged()
{
	QCoreApplication::instance()->removeTranslator(m_pTranslator);
	// Initiate, load and install the application translation files.
	QString locale_string = QLocale().name();
	QString file_name = QString("playdir_%1").arg(locale_string);
	if (m_pTranslator->load(file_name, "app/native/qm")) {
		QCoreApplication::instance()->installTranslator(m_pTranslator);
	}
}

QVariantList ApplicationUI::fetchFilesRecursively(const QStringList &path_list, const QStringList &file_filters)
{
	//qDebug() << "ApplicationUI::fetchFilesRecursively:" << path_list.join("/n");
	QVariantList ret;
	foreach(QString path, path_list) {
		//qDebug() << "###########" << path;
		ret << fetchFilesRecursively(path, file_filters);
	}
	return ret;
}

QVariantList ApplicationUI::fetchFilesRecursively(const QString &path, const QStringList &file_filters)
{
	qDebug() << ">>>>>>>>>>>>>>>>>>>>>" << path << ">>>>>>>>>>>>>>>>>>>>>>>>>>>";
	QVariantList ret;
	QFileInfo fi(path);
	if(fi.isFile()) {
		QString path = fi.canonicalFilePath();
		QString name = fi.fileName();
		qDebug() << name << "+++" << path;
		QVariantMap m;
		m["name"] = name;
		m["path"] = path;
		emit fileFound(m);
		ret << m;
	}
	else if(fi.isDir()) {
		QVariantList files = getDirContent(path, file_filters);
		foreach(QVariant file_v, files) {
			QVariantMap file_m = file_v.toMap();
			ret << fetchFilesRecursively(file_m.value("path").toString(), file_filters);
		}
	}
	qDebug() << "<<<<<<<<<<<<<<<<<<<<<<<" << path << "<<<<<<<<<<<<<<<<<<<<<<<";
	return ret;
}

bool ApplicationUI::dirExists(const QStringList &dir_path)
{
	QDir dir("/"%dir_path.join("/"));
	return dir.exists();
}

QVariantList ApplicationUI::getDirContent(const QStringList &parent_dir_path_list)
{
	QString parent_dir_path = "/"%parent_dir_path_list.join("/");
	return getDirContent(parent_dir_path, QStringList());
}

QVariantList ApplicationUI::getDirContent(const QString &parent_dir_path, const QStringList &file_filters)
{
	QVariantList ret;
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
	foreach(QFileInfo fi, fi_lst) {
		QString name = fi.fileName();
		if(names.contains(name)) {
			qDebug() << "--- ignoring duplicate entry:" << name;
			continue;
		}
		names << name;
		QString path = fi.absoluteFilePath();
		QString type = fi.isDir()? "dir": "file";
		QVariantMap m;
		m["name"] = name;
		m["path"] = path;
		m["type"] = type;
		//qDebug() << "\t" << name << "->" << path;
		ret << m;
	}
#else
	foreach(const FileInfo &fi, getDirContentPosix(parent_dir_path, file_filters)) {
		if(names.contains(fi.name)) {
			qDebug() << "--- ignoring duplicate entry:" << fi.name;
			continue;
		}
		names << fi.name;
		QVariantMap m;
		m["name"] = fi.name;
		m["path"] = fi.path;
		m["type"] = fi.type;
		//qDebug() << "\t" << fi.name << "->" << fi.path;
		ret << m;
	}
#endif
	//qDebug() << "ApplicationUI::getDirContent return" << ret.count() << "items";
	return ret;
}

/// workaround for 32bit readdir in Qt4 on device
QList<FileInfo> ApplicationUI::getDirContentPosix(const QString &parent_dir_path, const QStringList &file_filters)
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
				bool is_match = file_filters_ends.isEmpty();
				if(!is_match) {
					foreach(QString ff, file_filters_ends) {
						if(fi.name.endsWith(ff, Qt::CaseInsensitive)) {
							is_match = true;
							break;
						}
					}
				}
				if(is_match) ret << fi;
			}
		}
		(void) closedir(dp);
	}
	else qDebug() << "Couldn't open the directory:" << parent_dir_path;
	qSort(ret);
	return ret;
}

QVariant ApplicationUI::settings()
{
	QObject *o = m_settings;
	QVariant ret = QVariant::fromValue(o);
	return ret;
}

QVariantMap ApplicationUI::displayInfo()
{
	static QVariantMap ret;
	if(ret.isEmpty()) {
		bb::device::DisplayInfo display_info;
		//qDebug() << "display id is " << display_info->displayId();
		//qDebug() << "display name is " << display_info->displayName();
		//qDebug() << "display size is " << display_info->pixelSize().width() << ", " << display_info->pixelSize().height();
		QVariantMap ps;
		ps["width"] = display_info.pixelSize().width();
		ps["height"] = display_info.pixelSize().height();
		ret["pixelSize"] = ps;
	}
	return ret;
}
