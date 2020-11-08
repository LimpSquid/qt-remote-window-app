#pragma once

#include <QMainWindow>
#include <QScopedPointer>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class QPixmap;
class RemoteWindowSocket;
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    virtual void mousePressEvent(QMouseEvent *event) override;
    virtual void mouseReleaseEvent(QMouseEvent *event) override;

    Ui::MainWindow *ui;
    RemoteWindowSocket *socket_;

private slots:
    void onWindowCaptureRecieved(const QByteArray &data);
};
