#include "applicationui.h"
#include "theapp.h"
#include "settings.h"
#include "cover.h"
#include "findfile.h"
#include "trackmetadataresolver.h"
#include "logcollector.h"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/cascades/InvokeQuery>
#include <bb/cascades/Invocation>

#include <bb/system/phone/Phone>
#include <bb/system/phone/CallState>

#include <bb/multimedia/MediaState>

#include <bb/device/DisplayInfo>
#include <bbndk.h>

#include <QStringBuilder>
#include <QMetaType>
#include <QTimer>
#include <QVariant>
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

ApplicationUI::ApplicationUI(TheApp *app) :
QObject(app)
{
	m_trackMetaDataResolver = NULL;
#ifdef BB10_API_LEVEL_10_1
	/// 10.1 developpers foregot to declare mediastate metatype, fixed in 10.2
	qRegisterMetaType<bb::multimedia::MediaState::Type>();
#endif

	qmlRegisterType<FindFile>("app.lib", 1, 0, "FindFile");
	//qmlRegisterType<bb::cascades::pickers::FilePicker>("CascadesPickers", 1, 0,"FilePicker");

	// prepare the localization
	m_translator = new QTranslator(this);
	m_localeHandler = new LocaleHandler(this);
	QObject::connect(m_localeHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
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
	QCoreApplication::instance()->removeTranslator(m_translator);
	// Initiate, load and install the application translation files.
	QString locale_string = QLocale().name();
	QString file_name = QString("playdir_%1").arg(locale_string);
	if (m_translator->load(file_name, "app/native/qm")) {
		QCoreApplication::instance()->installTranslator(m_translator);
	}
}

QVariantList ApplicationUI::fetchFilesRecursively(const QStringList &path_list, const QStringList &file_ends_filter)
{
	//qDebug() << "ApplicationUI::fetchFilesRecursively:" << path_list.join("/n");
	QVariantList ret;
	foreach(QString path, path_list) {
		//qDebug() << "###########" << path;
		ret << fetchFilesRecursively(path, file_ends_filter);
	}
	return ret;
}

QVariantList ApplicationUI::fetchFilesRecursively(const QString &path, const QStringList &file_ends_filter)
{
	qDebug() << "fetchFilesRecursively >>>>>>>>>>>>>>>>>>>>>" << path << ">>>>>>>>>>>>>>>>>>>>>>>>>>>";
	QVariantList ret;
	QFileInfo fi(path);
	if(fi.isFile()) {
		QString path = fi.canonicalFilePath();
		QString name = fi.fileName();
		qDebug() << "+++" << path;
		QVariantMap m;
		m["name"] = name;
		m["path"] = path;
		m["type"] = "file";
		//emit fileFound(m);
		ret << m;
	}
	else if(fi.isDir()) {
		QList<FindFile::FileInfo> files = FindFile::getDirContent(path, file_ends_filter);
		qDebug() << "\t+++" << files.count() << path;
		foreach(const FindFile::FileInfo &fi, files) {
			//QVariantMap file_m = file_v.toMap();
			ret << fetchFilesRecursively(fi.path, file_ends_filter);
		}
	}
	qDebug() << "<<<<<<<<<<<<<<<<<<<<<<<" << path << "<<<<<<<<<<<<<<<<<<<<<<<";
	return ret;
}

QVariantList ApplicationUI::getDirContent(const QStringList &parent_dir_path_list, const QStringList &file_ends_filter)
{
	QVariantList ret;
	QString parent_dir_path = "/"%parent_dir_path_list.join("/");
	QList<FindFile::FileInfo> files = FindFile::getDirContent(parent_dir_path, file_ends_filter);
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

QVariant ApplicationUI::trackMetaDataResolver()
{
	if(!m_trackMetaDataResolver) {
		m_trackMetaDataResolver = new TrackMetaDataResolver(this);
	}
	QObject *o = m_trackMetaDataResolver;
	QVariant ret = QVariant::fromValue(o);
	return ret;
}

QVariant ApplicationUI::settings()
{
	QObject *o = theApp()->settings();
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


bool ApplicationUI::exportM3uFile(const QVariantList &list, const QString &file_path)
{
	if(file_path.isEmpty() || list.isEmpty()) {
		return false;
	}

	// Store M3U list in music folder of device.
	//QString fileName = "/accounts/1000/shared/music/" + listname + ".m3u";
	QFile file(file_path);
	if(!file.open(QIODevice::WriteOnly)) {
		return false;
	}

	QTextStream out(&file);
	out.setCodec("UTF-8");
	foreach(QVariant v, list) {
		QVariantMap item = v.toMap();
		QString path = item.value("path").toString().trimmed();
		if(!path.isEmpty()) {
			out << path << "\n";
		}
	}
	return true;
}

QVariant ApplicationUI::importM3uFile(const QString &file_path)
{
	QVariant ret = false;
	QFile file(file_path);
	if(file.open(QIODevice::ReadOnly)) {
		QTextStream in(&file);
		in.setCodec("UTF-8");
		QVariantList file_infos;
		while(true) {
			QString path = in.readLine().trimmed();
			if(path.isNull()) break;
			if(path.isEmpty()) continue;
			if(path[0] == '#') continue;
			QString name = path.section('/', -1);
			FindFile::FileInfo fi;
			fi.name = name;
			fi.path = path;
			fi.type = "file";
			file_infos << fi.toVariant();
		}
		ret = file_infos;
	}
	return ret;
}

namespace
{
	bb::cascades::Invocation *currentFileShareInvocation = NULL;
}

void ApplicationUI::shareFile(const QString &file_path, const QString &mime_type, const QString &action_id, const QString &target_id)
{
	using namespace bb::cascades;

	if(currentFileShareInvocation) {
		qWarning() << "Invocation in process !!!";
		return;
	}

	QUrl url = QUrl::fromLocalFile(file_path);
	qDebug() << "Creating share file invocation for:" << url.toString() << mime_type << action_id << target_id;
	currentFileShareInvocation = Invocation::create(InvokeQuery::create()
		.parent(this)
		.uri(url)
		.mimeType(mime_type)
		.invokeActionId(action_id)
		.invokeTargetId(target_id) //"sys.invokeTargetSelection"
	);

	connect(currentFileShareInvocation, SIGNAL(armed()), this, SLOT(onShareFileArmed()));
	connect(currentFileShareInvocation, SIGNAL(finished()), this, SLOT(onShareFileFinished()));
}

void ApplicationUI::onShareFileArmed()
{
	currentFileShareInvocation->trigger("bb.action.SHARE");
}

void ApplicationUI::onShareFileFinished()
{
	currentFileShareInvocation->deleteLater();
	currentFileShareInvocation = NULL;
}

void ApplicationUI::shareLogFile()
{
	QString working_dir = QDir::currentPath();
	QString log_file = working_dir + "/tmp/log.txt";
	QFile f(log_file);
	if(f.open(QFile::WriteOnly)) {
		LogCollector lc;
		QByteArray log = lc.collectLog();
		f.write(log);
		f.close();
		shareFile(log_file, "text/plain");
	}
}

