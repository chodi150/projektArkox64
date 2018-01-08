#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

extern "C" double func(uchar* data, int x, int y, double s, double a, double b, double c);

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_drawButton_clicked();

private:
    Ui::MainWindow *ui;
    void drawCurves();
};

#endif // MAINWINDOW_H
