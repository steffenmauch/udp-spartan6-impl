//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Steffen Mauch                             ////
////     steffen.mauch (at) gmail.com                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QMainWindow>
#include <QCoreApplication>
#include <QUdpSocket>
#include <QPushButton>
#include <QGridLayout>
#include <QWidget>
#include <QTextEdit>
#include <QCheckBox>

#include "optionpane.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void processPendingDatagrams();
    void sendUDPDatagram();
    void clearText();
    void showOptions();

private:
    QUdpSocket *udpSocket;
    QPushButton *send;
    QPushButton *clear;
    QPushButton *exit;
    QPushButton *option;

    optionPane *optionWidget;

    QGridLayout *layout;
    QTextEdit *text;
    QCheckBox *led1;
    QCheckBox *led2;
    QCheckBox *led3;
    QCheckBox *led4;

};

#endif // MAINWINDOW_H
