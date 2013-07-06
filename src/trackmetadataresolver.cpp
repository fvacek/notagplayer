/*
 * trackmetadataresolver.cpp
 *
 *  Created on: Jul 5, 2013
 *      Author: fvacek@blackberry.com
 */
#include "trackmetadataresolver.h"

#include <bb/multimedia/MediaPlayer>

#include <QTimer>

//const QString TrackMetaDataResolver::FileInfo::FILE_TYPE_DIR = "dir";
const QString TrackMetaDataResolver::FileInfo::FILE_TYPE_FILE = "file";

TrackMetaDataResolver::TrackMetaDataResolver(QObject *parent)
: QObject(parent)
{
	m_metaDataResolverWatchDog = NULL;
	m_metaDataResolver = NULL;
}

TrackMetaDataResolver::~TrackMetaDataResolver()
{
	// TODO Auto-generated destructor stub
}

void TrackMetaDataResolver::abort()
{
	m_requestQueue.clear();
	resolveFinish(QVariant());
}

void TrackMetaDataResolver::enqueue(const QVariantList &file_infos)
{
	QList<FileInfo> to_enqueue;
	//qDebug() << "################## enqueue:" << file_infos.count();
	for(int i=0; i<file_infos.count(); i++) {
		FileInfo fi(file_infos[i].toMap());
		//qDebug() << "################## add to queue:" << fi.fileType() << fi.filePath();
		if(fi.fileType() == FileInfo::FILE_TYPE_FILE) {
			fi["index"] = i;
			to_enqueue << fi;
		}
	}
	m_requestQueue << to_enqueue;
	processQueue();
}

void TrackMetaDataResolver::processQueue()
{
	if(!m_metaDataResolverWatchDog || !m_metaDataResolverWatchDog->isActive()) {
		resolveFirst();
	}
}

void TrackMetaDataResolver::onMetaDataChanged(const QVariantMap &meta_data)
{
	QString file_path = m_metaDataResolver->sourceUrl().toString();
	//qDebug() << "################## got metadata:" << meta_data.count();
	//qDebug() << "path:" << file_path;
	if(!meta_data.value("title").toString().isEmpty()) {
		QVariantMap m;
		QMapIterator<QString, QVariant> it(meta_data);
		while(it.hasNext()) {
		    it.next();
		    //qDebug() << it.key() << ": " << it.value().toString();
		    if(it.key() == "title") {
		    	m[it.key()] = it.value();
		    }
		    else if(it.key() == "track") {
		    	int i = it.value().toInt();
		    	if(i > 0) m[it.key()] = i;
		    }
		    else if(it.key() == "album") {
		    	QString s = it.value().toString().trimmed();
		    	if(!s.isEmpty()) m[it.key()] = s;
		    }
		    else if(it.key() == "artist") {
		    	QString s = it.value().toString().trimmed();
		    	if(!s.isEmpty()) m[it.key()] = s;
		    }
		}
		//qDebug() << "resolved track metadata";
		resolveFinish(m);
	}
}

void TrackMetaDataResolver::resolveFinish(const QVariant &meta_data)
{
	if(m_metaDataResolver) {
		m_metaDataResolver->setSourceUrl(QUrl());
		m_metaDataResolver->reset();
	}
	if(m_metaDataResolverWatchDog) {
		m_metaDataResolverWatchDog->stop();
	}
	if(!m_requestQueue.isEmpty()) {
		FileInfo file_info = m_requestQueue.takeFirst();
		qDebug() << "<<<<<<<<<<<<<<<  resolved track metadata:" << meta_data.typeName();
		emit trackMetaDataResolved(file_info.fileIndex(), file_info.filePath(), meta_data);
	}
	resolveFirst();
}

void TrackMetaDataResolver::onWatchDogTimeout()
{
	qDebug() << "============================= TrackMetaDataResolver::onWatchDogTimeout() ============================";
	resolveFinish(QVariant());
}

void TrackMetaDataResolver::resolveFirst()
{
	if(m_requestQueue.isEmpty()) return;
	FileInfo file_info = m_requestQueue.first();
	QString file_path = file_info.filePath();
	qDebug() << ">>>>>>>>>>>>>>> resolving metadata for:" << file_path;
	if(!m_metaDataResolver) {
		m_metaDataResolver = new bb::multimedia::MediaPlayer(this);
		connect(m_metaDataResolver, SIGNAL(metaDataChanged(QVariantMap)), this, SLOT(onMetaDataChanged(QVariantMap)));
	}
	if(!m_metaDataResolverWatchDog) {
		m_metaDataResolverWatchDog = new QTimer(this);
		m_metaDataResolverWatchDog->setSingleShot(true);
		m_metaDataResolverWatchDog->setInterval(500);
		connect(m_metaDataResolverWatchDog, SIGNAL(timeout()), this, SLOT(onWatchDogTimeout()));
	}
	bool ok = false;
	bb::multimedia::MediaError::Type err = m_metaDataResolver->setSourceUrl(file_path);
	if(err == bb::multimedia::MediaError::None) {
		err = m_metaDataResolver->prepare();
		if(err == bb::multimedia::MediaError::None) {
			//qDebug() << "============================= prepared ============================";
			m_metaDataResolverWatchDog->start();
			ok = true;
			/*
			QVariantMap m = m_metaDataResolver->metaData();
			qDebug() << m.count() << "************* got metadata for:" << m_metaDataResolver->sourceUrl().toString();
			QMapIterator<QString, QVariant> it(m);
			while(it.hasNext()) {
			    it.next();
			    qDebug() << it.key() << ": " << it.value().toString();
			}
			*/
		}
		else qDebug() << "prepare error:" << err;
	}
	else qDebug() << "setSourceUrl error:" << err;
	if(!ok) {
		resolveFinish(QVariant());
	}
}

