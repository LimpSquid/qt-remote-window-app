#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <remotewindowsocket.h>
#include <QHostAddress>
#include <QMouseEvent>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    setMouseTracking(true);

    socket_ = new RemoteWindowSocket(this);
    socket_->connectToHost(QHostAddress::LocalHost, 55555);
    QObject::connect(socket_, &RemoteWindowSocket::windowCaptureReceived, this, &MainWindow::onWindowCaptureRecieved);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::mousePressEvent(QMouseEvent *event)
{
    socket_->sendMousePress(event->button(), event->pos(), event->modifiers());
}

void MainWindow::mouseReleaseEvent(QMouseEvent *event)
{
    socket_->sendMouseRelease(event->button(), event->pos(), event->modifiers());
}

void MainWindow::onWindowCaptureRecieved(const QByteArray &data)
{
    QPixmap pixmap;
    pixmap.loadFromData(data);

    ui->image->setPixmap(pixmap);
}

