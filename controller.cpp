#include "controller.h"

Controller::Controller(QQmlContext *context) : QObject()
{
    context->setContextProperty("ctrl", this); //讓qml可以接收到controller

    //init
    m_listPoint.clear();
}

Controller::~Controller() {

}

void Controller::addPolygon4(QPoint p1, QPoint p2, QPoint p3, QPoint p4)
{
    m_listPoint.append(p1);
    m_listPoint.append(p2);
    m_listPoint.append(p3);
    m_listPoint.append(p4);
}
