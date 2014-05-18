APP_NAME = notagplayer

#CONFIG += qtc-build

# use 64bit readdir
# this is not needed if QT_NO_READDIR64 is undefined
# for more info see findfile.cpp
DEFINES += _FILE_OFFSET_BITS=64
DEFINES += _LARGEFILE64_SOURCE=1

LIBS += -lbbdevice
LIBS += -lbbsystem
LIBS += -lbbmultimedia
#LIBS += -lbbcascadespickers
#LIBS += -lpng

qtc-build {
  CONFIG += qt warn_on
  QT += declarative xml
  QT -= gui

  LIBS += -lbbdata -lbb -lbbcascades

  include(src/src.pri)
}
else {
  CONFIG += qt warn_on cascades10
  include(config.pri)
}


