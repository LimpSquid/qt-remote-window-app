QT += quick

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        customimageprovider.cpp \
        main.cpp \
        remotewindowsocketwrapper.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../dependencies/qt-remote-window-lib/release/ -lqt-remote-window-lib
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../dependencies/qt-remote-window-lib/debug/ -lqt-remote-window-lib
else:unix:!macx: LIBS += -L$$OUT_PWD/../dependencies/qt-remote-window-lib/ -lqt-remote-window-lib

INCLUDEPATH += $$PWD/../dependencies/qt-remote-window-lib
DEPENDPATH += $$PWD/../dependencies/qt-remote-window-lib

win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../dependencies/qt-remote-window-lib/release/libqt-remote-window-lib.a
else:win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../dependencies/qt-remote-window-lib/debug/libqt-remote-window-lib.a
else:win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../dependencies/qt-remote-window-lib/release/qt-remote-window-lib.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../dependencies/qt-remote-window-lib/debug/qt-remote-window-lib.lib
else:unix:!macx: PRE_TARGETDEPS += $$OUT_PWD/../dependencies/qt-remote-window-lib/libqt-remote-window-lib.a

HEADERS += \
    customimageprovider.h \
    remotewindowsocketwrapper.h
