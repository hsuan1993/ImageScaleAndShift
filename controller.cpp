#include "controller.h"
#include <QGuiApplication>
#include <qtconcurrentrun.h> //pro file need to add "QT += concurrent"

/*
 * constructor
 */
Controller::Controller(QQmlContext *context) : QObject()
{
    context->setContextProperty("ctrl", this); //讓qml可以接收到controller

    //ini
    QString iniPath = QString("%1/imgTest.ini").arg(QCoreApplication::applicationDirPath());
    m_pSettings = new QSettings(iniPath, QSettings::IniFormat);
    m_pSettings->setIniCodec("UTF-8");

    //init
    m_listPoint.clear();
}

/*
 * Destructor
 */
Controller::~Controller() {
    if (m_pSettings != NULL) {
        delete m_pSettings;
    }
}

void Controller::setSettingsValue(QString key, QVariant value)
{
    m_pSettings->setValue(key, value);
    m_pSettings->sync();
}

QVariant Controller::getSettingsValue(QString key)
{
    QVariant result = m_pSettings->value(key);
    if(result.toString() == "false" || result.toString() == "true") {
        return result.toBool();
    }
    return result;
}

void Controller::setRectIDMap(int no, int rectID)
{
    m_mapRectID[no] = rectID;
}

int  Controller::getRectIDMap(int no)
{
    if (m_mapRectID.contains(no)) {
        return m_mapRectID[no];
    } else {
        return -1;
    }
}

int  Controller::getRectNoMap(int rectID)
{
    int key = m_mapRectID.key(rectID, -1);
    return key;
}

void Controller::addPolygon4(QPoint p1, QPoint p2, QPoint p3, QPoint p4)
{
    m_listPoint.append(p1);
    m_listPoint.append(p2);
    m_listPoint.append(p3);
    m_listPoint.append(p4);

    //update data base
    QtConcurrent::run(this, &Controller::updatePolygonINIFile);
}

void Controller::updatePolygonINIFile() {
    QString key = "";
    int rectCount = 0;
    int pointCount = 0;

    qDebug()<<__func__<<m_listPoint;

    for (int i=0;i<m_listPoint.count();i+=4){
        key = QString("RS/AREA_IDX_%1").arg(rectCount);
        setSettingsValue(key, m_mapRectID[rectCount]);
        for(int j=0;j<4;j++) {
            key = QString("Points/x%1").arg(pointCount);
            setSettingsValue(key, m_listPoint[i+j].x());
            key = QString("Points/y%1").arg(pointCount);
            setSettingsValue(key, m_listPoint[i+j].y());
            pointCount++;
        }
        rectCount++;
    }

    key = QString("Points/Rect_Number");
    setSettingsValue(key, rectCount);
}

void Controller::readPolygonINIFile() {
    QList<QString> listRectItem;
    m_mapRectID.clear();
    m_listPoint.clear();

    QString key = "";
    int rectNumber = getSettingsValue("Points/Rect_Number").toInt();

    for (int i=0;i<rectNumber;i++) {
        key = QString("RS/AREA_IDX_%1").arg(i);
        int id = getSettingsValue(key).toInt();
        m_mapRectID[i] = id;
        for (int j=0;j<4;j++) {
            key = QString("Points/x%1").arg(i*4+j);
            int x = getSettingsValue(key).toInt();
            key = QString("Points/y%1").arg(i*4+j);
            int y = getSettingsValue(key).toInt();
            m_listPoint<<QPoint(x,y);
        }
    }

    listRectItem<<QString("%1").arg(m_listPoint.count());
    for (int i=0;i<m_listPoint.count();i++){
        listRectItem<<QString("%1 %2").arg(m_listPoint[i].x()).arg(m_listPoint[i].y());
    }
    qDebug()<<__func__<<listRectItem;

    emit reloadROIInfo(listRectItem);
}
