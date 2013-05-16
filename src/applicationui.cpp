#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <QFileInfo>
#include <QDir>
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

QVariantList ApplicationUI::getFilesRecursively(const QString &parent_dir_path, const QString &file_filters)
{
	QStringList filters = file_filters.split(' ', QString::SkipEmptyParts);
	for(int i=0; i<filters.count(); i++) {
		filters[i] = "*." + filters[i];
	}
	QDir dir(parent_dir_path);
	return getFilesRecursively(dir, filters);
}

QVariantList ApplicationUI::getFilesRecursively(const QDir &parent_dir, const QStringList &file_filters)
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
		QDir dir(fi.canonicalFilePath());
		ret << getFilesRecursively(dir, file_filters);
	}
	qDebug() << "<<<<<<<<<<<<<<<<<<<<<<<" << parent_dir.canonicalPath() << "<<<<<<<<<<<<<<<<<<<<<<<";
	return ret;
}
