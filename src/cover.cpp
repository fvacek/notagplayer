/*
 * cover.cpp
 *
 *  Created on: May 27, 2013
 *      Author: fvacek
 */

#include "cover.h"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/Container>

#include <QTimer>

using namespace bb::cascades;

Cover::Cover(QObject *parent)
: SceneCover(parent)
{
	m_isActive = false;

	m_updateTimer = new QTimer(this);
	m_updateTimer->setInterval(3000);
    QObject::connect(m_updateTimer, SIGNAL(timeout()), this, SLOT(update()));

    {
		QmlDocument *qml = QmlDocument::create("asset:///cover.qml").parent(this);
		Container *cont = qml->createRootObject<Container>();
        QObject::connect(this, SIGNAL(updateQml()), cont, SLOT(update()));
        qml->setContextProperty("CppCover", this);
	    setContent(cont);
	}
	QObject::connect(Application::instance(), SIGNAL(thumbnail()), this, SLOT(backgrounded()));
	QObject::connect(Application::instance(), SIGNAL(fullscreen()), this, SLOT(foregrounded()));
}

Cover::~Cover()
{
}

void Cover::foregrounded()
{
	m_isActive = false;
	m_updateTimer->stop();
}

void Cover::backgrounded()
{
	m_isActive = true;
    update();
    m_updateTimer->start();
}

void Cover::update() {

    if (m_isActive) {
        emit updateQml();
    }
}
