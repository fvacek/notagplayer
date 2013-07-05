/*
 * trackmetadataresolver.h
 *
 *  Created on: Jul 5, 2013
 *      Author: fvacek
 */

#ifndef TRACKMETADATARESOLVER_H_
#define TRACKMETADATARESOLVER_H_

#include <QObject>
#include <QVariantMap>

namespace bb
{
    namespace multimedia
    {
    	class MediaPlayer;
    }
}

class QTimer;

class TrackMetaDataResolver: public QObject
{
	Q_OBJECT
public:
	explicit TrackMetaDataResolver(QObject *parent = NULL);
	virtual ~TrackMetaDataResolver();
public:
	Q_INVOKABLE void abort();
	Q_INVOKABLE void enqueue(const QVariantList &file_infos);
signals:
	void trackMetaDataResolved(int index, const QString &path, const QVariant &meta_data);
private:
	void processQueue();
	void resolveFirst();
	void resolveFinish(const QVariant &meta_data);
private slots:
	void onMetaDataChanged(const QVariantMap &meta_data);
	void onWatchDogTimeout();
private:
	class FileInfo : public QVariantMap
	{
	public:
		FileInfo() : QVariantMap() {}
		FileInfo(const QVariantMap &m) : QVariantMap(m) {}
	public:
		//static const QString FILE_TYPE_DIR;
		static const QString FILE_TYPE_FILE;
	public:
		QString fileType() const {return value("type").toString();}
		QString filePath() const {return value("path").toString();}
		//QString fileName() const {return value("name").toString();}
		int fileIndex() const {return value("index").toInt();}
	};
private:
	QList<FileInfo> m_requestQueue;
    bb::multimedia::MediaPlayer *m_metaDataResolver;
    QTimer *m_metaDataResolverWatchDog;
};

#endif /* TRACKMETADATARESOLVER_H_ */
