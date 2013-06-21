#include "applicationui.hpp"
#include "appglobals.h"
#include "settings.h"
#include "cover.h"
#include "findfile.h"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/multimedia/MediaState>

#include <bb/system/phone/Phone>
#include <bb/system/phone/CallState>

#include <bb/device/DisplayInfo>
#include <bbndk.h>

#include <QStringBuilder>
#include <QMetaType>
#include <QDebug>

#if BBNDK_VERSION_AT_LEAST(10,2,0)
      // code to compile on BBNDK 10.1.0 or higher
#else
	#define BB10_API_LEVEL_10_1
#endif

#ifdef BB10_API_LEVEL_10_1
/// 10.1 developpers foregot to declare mediastate metatype, fixed in 10.2
Q_DECLARE_METATYPE(bb::multimedia::MediaState::Type);
#endif

using namespace bb::cascades;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
QObject(app)
{
#ifdef BB10_API_LEVEL_10_1
	/// 10.1 developpers foregot to declare mediastate metatype, fixed in 10.2
	qRegisterMetaType<bb::multimedia::MediaState::Type>();
#endif

	qmlRegisterType<FindFile>("app.lib", 1, 0, "FindFile");

	m_settings = new Settings(this);
	// prepare the localization
	m_pTranslator = new QTranslator(this);
	m_pLocaleHandler = new LocaleHandler(this);
	QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
	// initial load
	onSystemLanguageChanged();

	{
		bb::system::phone::Phone *phone = new bb::system::phone::Phone(this);
		//phone.initiateCellularCall("777110277");
		bool ok = connect(phone, SIGNAL(callUpdated(const bb::system::phone::Call &)), this, SLOT(onPhoneCallUpdated(const bb::system::phone::Call &)));
		qDebug() << "<<<<<<<<<<<<<<<< connecting phone:" << ok;
	}

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
		qDebug() << "+++" << path;
		QVariantMap m;
		m["name"] = name;
		m["path"] = path;
		emit fileFound(m);
		ret << m;
	}
	else if(fi.isDir()) {
		QList<FindFile::FileInfo> files = FindFile::getDirContent(path, file_filters);
		//qDebug() << "+++" << files.count() << path;
		foreach(const FindFile::FileInfo &fi, files) {
			//QVariantMap file_m = file_v.toMap();
			ret << fetchFilesRecursively(fi.path, file_filters);
		}
	}
	qDebug() << "<<<<<<<<<<<<<<<<<<<<<<<" << path << "<<<<<<<<<<<<<<<<<<<<<<<";
	return ret;
}

QVariantList ApplicationUI::getDirContent(const QStringList &parent_dir_path_list)
{
	QVariantList ret;
	QString parent_dir_path = "/"%parent_dir_path_list.join("/");
	QList<FindFile::FileInfo> files = FindFile::getDirContent(parent_dir_path);
	foreach(const FindFile::FileInfo &fi, files) {
		//QVariantMap file_m = file_v.toMap();
		ret << fi.toVariant();
	}
	return ret;
}

bool ApplicationUI::dirExists(const QStringList &dir_path)
{
	return FindFile::dirExists("/"%dir_path.join("/"));
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

void ApplicationUI::onPhoneCallUpdated(const bb::system::phone::Call &call)
{
	qDebug() << "*************** onPhoneCallUpdated valid call:" << call.isValid();
	bool phone_active = false;
	if(call.isValid()) {
		bb::system::phone::CallState::Type call_state = call.callState();
		qDebug() << "call state:" << call_state;
		qDebug() << "call type:" << call.callType();
		switch(call_state) {
		case bb::system::phone::CallState::Incoming:
		case bb::system::phone::CallState::Connecting:
		case bb::system::phone::CallState::RemoteRinging:
		case bb::system::phone::CallState::Connected:
				phone_active = true;
				break;
			default:
				break;
		}
	}
	emit phoneActivityChanged(phone_active);
}
