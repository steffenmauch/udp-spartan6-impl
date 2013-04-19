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

#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("UDP Monitor");

    send = new QPushButton("Send Packet");
    clear = new QPushButton("Clear");
    exit = new QPushButton("Quit");
    option = new QPushButton("Option");

    layout = new QGridLayout();
    text = new QTextEdit();
    led1 = new QCheckBox("LED 1");
    led2 = new QCheckBox("LED 2");
    led3 = new QCheckBox("LED 3");
    led4 = new QCheckBox("LED 4");

    udpSocket = new QUdpSocket(this);
    optionWidget = new optionPane();

    QWidget *centralWidget = new QWidget(this);

    text->setReadOnly(TRUE);
    layout->addWidget(send,0,1);
    layout->addWidget(led1,0,2);
    layout->addWidget(led2,0,3);
    layout->addWidget(led3,0,4);
    layout->addWidget(led4,0,5);
    layout->addWidget(text,1,1,1,5);
    layout->addWidget(clear,2,1);
    layout->addWidget(option,2,3);
    layout->addWidget(exit,2,5);

    centralWidget->setLayout(layout);
    setCentralWidget(centralWidget);

    resize(400,200);

   //udpSocket->connectToHost(192.168.1.1);
    //udpSocket->bind(81, QHostAddress:);
    bool res;
    int port = 8100;
    res = udpSocket->bind(QHostAddress::Any,port);

    QString temp;
    QTextStream(&temp) << "Binding " << QString(res?"SUCCESSFUL":"ERROR") << " on port: " << port;

    text->append(temp);

    connect(udpSocket, SIGNAL(readyRead()), this, SLOT(processPendingDatagrams()));
    connect(send, SIGNAL(pressed()), this, SLOT(sendUDPDatagram()));
    connect(exit, SIGNAL(pressed()), qApp, SLOT(quit()));
    connect(clear, SIGNAL(pressed()), this, SLOT(clearText()));
    connect(option, SIGNAL(pressed()), this, SLOT(showOptions()));

}

void MainWindow::sendUDPDatagram()
{
    QString temp;
    QTextStream(&temp) << "Send: "<< "LED1:  " << led1->isChecked() << "  LED2:  " << led2->isChecked()
                    << "  LED3:  " << led3->isChecked() << "  LED4:  " << led4->isChecked();

    text->append(temp);


    QUdpSocket udpSocket2;
    int temp_int = led1->isChecked() + led2->isChecked()*2 + led3->isChecked()*4 + led4->isChecked()*8;

    QByteArray datagram;
    datagram.append( (char) temp_int );

    datagram.append("komtttttttisch- brauche ich längere Pakete?");
    qDebug() << "here: " << temp_int;
    //QHostAddress myBroadcastAddress = QHostAddress("141.24.208.117");
    //udpSocket2.writeDatagram(datagram.data(), datagram.size(), myBroadcastAddress, 8001);
    QHostAddress myBroadcastAddress1 = QHostAddress("192.168.1.1");
    udpSocket2.writeDatagram(datagram.data(), datagram.size(), myBroadcastAddress1, 8100);

}

void MainWindow::clearText()
{
    text->clear();
}

void MainWindow::showOptions()
{
    qDebug() << "Show Options";
    optionWidget->show();
}

void MainWindow::processPendingDatagrams()
{
    qDebug() << "Here I am";
    QByteArray datagram;

    do {
        datagram.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(datagram.data(), datagram.size());
    } while (udpSocket->hasPendingDatagrams());

    QString temp;
    QTextStream(&temp) << "Recieve: " << datagram.data() << "Length: " << datagram.length();

    text->append(temp);
}

MainWindow::~MainWindow()
{
    delete(udpSocket);
    delete(send);
    delete(clear);
    delete(exit);
    delete(option);
    delete(optionWidget);

    delete(layout);
    delete(text);
    delete(led1);
    delete(led2);
    delete(led3);
    delete(led4);
}
