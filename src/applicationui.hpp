#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

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

/*!
 * @brief Application object
 *
 *
 */

class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI(bb::cascades::Application *app);
    virtual ~ApplicationUI();
private slots:
    void onSystemLanguageChanged();
    void onPhoneCallUpdated(const bb::system::phone::Call &call);
public:
    Q_INVOKABLE QVariantList fetchFilesRecursively(const QStringList &path_list, const QStringList &file_filters);
    Q_INVOKABLE QVariantList getDirContent(const QStringList &parent_dir_path, const QStringList &file_filters = QStringList());
    Q_INVOKABLE bool dirExists(const QStringList &dir_path);

	Q_INVOKABLE QVariantMap displayInfo();

	Q_INVOKABLE QVariant trackMetaDataResolver();

	Q_INVOKABLE QVariant settings();
	Q_INVOKABLE QString buildDate() { return __DATE__; }

	Q_INVOKABLE bool exportM3uFile(const QVariantList &list, const QString &listname);
	Q_INVOKABLE QVariant importM3uFile(const QString &file_name);

private:
    QVariantList fetchFilesRecursively(const QString &path, const QStringList &file_filters);
    void resolveTrackMetaDataFinish(const QString &path, const QVariant &meta_data);
signals:
	//void fileFound(const QVariant &file_info);
	void phoneActivityChanged(bool phone_active);
private:
    QTranslator *m_pTranslator;
    bb::cascades::LocaleHandler *m_pLocaleHandler;
    Settings *m_settings;
    TrackMetaDataResolver *m_trackMetaDataResolver;
};

#endif /* ApplicationUI_HPP_ */
