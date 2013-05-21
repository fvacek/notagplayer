#include "applicationui.hpp"
#include "settings.h"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <QFileInfo>
#include <QDir>
#include <QStringBuilder>
#include <QDebug>

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

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("ApplicationUI", this);

    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    app->setScene(root);
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
	QDir parent_dir(parent_dir_path);
	qDebug() << "ApplicationUI::getDirContent" << parent_dir.canonicalPath();
	/// don't know why, but entryInfoList() returns some duplicates
	QSet<QString> names;
	QFileInfoList fi_lst;
	QDir::Filters filters = QDir::NoDotAndDotDot | QDir::AllDirs | QDir::Files | QDir::Readable;
	if(file_filters.isEmpty()) fi_lst = parent_dir.entryInfoList(filters, QDir::DirsFirst);
	else fi_lst = parent_dir.entryInfoList(file_filters, filters, QDir::DirsFirst);
	foreach(QFileInfo fi, fi_lst) {
		QString name = fi.fileName();
		if(names.contains(name)) continue;
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
	qDebug() << "ApplicationUI::getDirContent return" << ret.count() << "items";
	return ret;
}

QVariant ApplicationUI::settings()
{
	QObject *o = m_settings;
	QVariant ret = QVariant::fromValue(o);
	return ret;
}

