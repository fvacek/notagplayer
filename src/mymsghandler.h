#include <QDebug>

#include <iostream>

namespace {

    void myMsgHandler(QtMsgType t, const char *s)
    {
        switch(t) {
            case QtDebugMsg:
                std::cerr << "[D]" << s << std::endl;
                break;
            case QtWarningMsg:
                std::cerr << "[W]" << s << std::endl;
                break;
            case QtCriticalMsg:
                std::cerr << "[E]" << s << std::endl;
                break;
            case QtFatalMsg:
                std::cerr << "[F]" << s << std::endl;
                break;
            default:
                std::cerr << "[.]" << s << std::endl;
                break;
        }
    }
}

