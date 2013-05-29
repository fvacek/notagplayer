APP_NAME = notagplayer

CONFIG += qt warn_on cascades10

# use 64bit readdir
DEFINES += _FILE_OFFSET_BITS=64
DEFINES += _LARGEFILE64_SOURCE=1

LIBS += -lbbdevice

include(config.pri)
