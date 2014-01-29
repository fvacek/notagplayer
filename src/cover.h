/*
 * cover.h
 *
 *  Created on: May 27, 2013
 *      Author: fvacek
 */

#ifndef COVER_H_
#define COVER_H_

#include <bb/cascades/SceneCover>

class Cover : public bb::cascades::SceneCover
{
Q_OBJECT
public:
	Cover(QObject *parent = NULL);
	virtual ~Cover();
private slots:
	void update();
	void foregrounded();
	void backgrounded();
signals:
    void updateQml();
private:
	bool m_isActive;
	QTimer *m_updateTimer;
};

#endif /* COVER_H_ */
