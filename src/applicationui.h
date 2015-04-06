#ifndef ApplicationUI_H_
#define ApplicationUI_H_

#include <QObject>
#include <QVariantList>
#include <QStringList>

class TrackMetaDataResolver;
class Settings;
class QDir;

namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
    }
    namespace system
    {
		namespace phone
		{
			class Call;
		}
    }
}

class QTranslator;
class TheApp;

class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI(TheApp *app);
    virtual ~ApplicationUI();
private slots:
    void onSystemLanguageChanged();
    void onPhoneCallUpdated(const bb::system::phone::Call &call);
    void onShareFileArmed();
    void onShareFileFinished();
public:
    Q_INVOKABLE QVariantList fetchFilesRecursively(const QStringList &path_list, const QStringList &file_ends_filter);
    Q_INVOKABLE QVariantList getDirContent(const QStringList &parent_dir_path, const QStringList &file_ends_filter = QStringList());
    Q_INVOKABLE bool dirExists(const QStringList &dir_path);

	Q_INVOKABLE QVariantMap displayInfo();

	Q_INVOKABLE QVariant trackMetaDataResolver();

	Q_INVOKABLE QVariant settings();
	Q_INVOKABLE QString buildDate() { return __DATE__; }

	Q_INVOKABLE bool exportM3uFile(const QVariantList &list, const QString &listname);
	Q_INVOKABLE QVariant importM3uFile(const QString &file_name);

	Q_INVOKABLE void shareFile(const QString &file_name, const QString &mime_type = QString(), const QString &action_id = QString(), const QString &target_id = QString());
	Q_INVOKABLE void shareLogFile();
private:
    QVariantList fetchFilesRecursively(const QString &path, const QStringList &file_ends_filter);
    void resolveTrackMetaDataFinish(const QString &path, const QVariant &meta_data);
signals:
	//void fileFound(const QVariant &file_info);
	void phoneActivityChanged(bool phone_active);
private:
    QTranslator *m_translator;
    bb::cascades::LocaleHandler *m_localeHandler;
    TrackMetaDataResolver *m_trackMetaDataResolver;
};

#endif /* ApplicationUI_H_ */
