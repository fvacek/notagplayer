#include "applicationui.hpp"

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

QVariantList ApplicationUI::fetchFilesRecursively(const QStringList &parent_dir_path, const QStringList &file_filters)
{
	QString path = '/'%parent_dir_path.join("/");
	QDir dir(path);
	return fetchFilesRecursively(dir, file_filters);
}

QVariantList ApplicationUI::fetchFilesRecursively(const QDir &parent_dir, const QStringList &file_filters)
{
	qDebug() << ">>>>>>>>>>>>>>>>>>>>>" << parent_dir.canonicalPath() << ">>>>>>>>>>>>>>>>>>>>>>>>>>>";
	QVariantList ret;
	foreach(QFileInfo fi, parent_dir.entryInfoList(file_filters, QDir::NoDot | QDir::NoDotDot | QDir::Files | QDir::Readable)) {
		QString path = fi.canonicalFilePath();
		QString name = fi.fileName();
		qDebug() << name << "+++" << path;
		QVariantMap m;
		m["name"] = name;
		m["path"] = path;
		emit fileFound(m);
		ret << m;
	}
	foreach(QFileInfo fi, parent_dir.entryInfoList(QStringList(), QDir::NoDot | QDir::NoDotDot | QDir::Dirs | QDir::Readable)) {
		QDir dir(fi.absoluteFilePath());
		ret << fetchFilesRecursively(dir, file_filters);
	}
	qDebug() << "<<<<<<<<<<<<<<<<<<<<<<<" << parent_dir.canonicalPath() << "<<<<<<<<<<<<<<<<<<<<<<<";
	return ret;
}

bool ApplicationUI::dirExists(const QStringList &dir_path)
{
	QDir dir("/"%dir_path.join("/"));
	return dir.exists();
}

QVariantList ApplicationUI::getDirContent(const QStringList &parent_dir_path)
{
	QVariantList ret;
	QDir parent_dir("/"%parent_dir_path.join("/"));
	qDebug() << "ApplicationUI::getDirContent" << parent_dir.canonicalPath();
	/// don't know why entryInfoList() returns some duplicates
	QSet<QString> names;
	foreach(QFileInfo fi, parent_dir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries | QDir::Readable, QDir::DirsFirst)) {
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

QVariant ApplicationUI::getSettings(const QString &path, const QVariant &default_value)
{
	QSettings settings;
	QVariant ret = settings.value(path, default_value);
	qDebug() << "get settings" << path << "->" << ret.toString() << ret.typeName();
	return ret;
}

void ApplicationUI::setSettings(const QString &path, const QVariant &val)
{
	QSettings settings;
	qDebug() << "set settings" << path << "->" << val.toString() << val.typeName();
	settings.setValue(path, val);
}
