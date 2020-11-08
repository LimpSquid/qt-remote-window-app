TEMPLATE = subdirs
SUBDIRS = \
    qt-remote-window-lib \
    app

# Dependencies
qt-remote-window-lib.subdir = dependencies/qt-remote-window-lib

# App
app.subdir = app
app.depends = qt-remote-window-lib
