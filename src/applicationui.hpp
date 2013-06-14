#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <QVariantList>

class QDir;
class Settings;

namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
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
public:
    Q_INVOKABLE QVariantList fetchFilesRecursively(const QStringList &path_list, const QStringList &file_filters);
    Q_INVOKABLE QVariantList getDirContent(const QStringList &parent_dir_path);
    Q_INVOKABLE bool dirExists(const QStringList &dir_path);

	Q_INVOKABLE QVariantMap displayInfo();

	Q_INVOKABLE QVariant settings();
private:
    QVariantList fetchFilesRecursively(const QString &path, const QStringList &file_filters);
signals:
	void fileFound(const QVariant &file_info);
	//void aboutToQuit();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    Settings *m_settings;
};

#endif /* ApplicationUI_HPP_ */
