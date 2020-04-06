#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QQmlContext>
#include <QPoint>
#include <QSettings>

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QQmlContext *context);
    virtual ~Controller();

    //ini
    Q_INVOKABLE QVariant   getSettingsValue(QString key);
    Q_INVOKABLE void       setSettingsValue(QString key, QVariant value);
    //polygon
    Q_INVOKABLE void       disablePolygon4(int rectIndex);
    Q_INVOKABLE void       modifyPolygon4(int rectIndex, int pointIndex, QPoint p);
    Q_INVOKABLE void       addPolygon4(QPoint p1, QPoint p2, QPoint p3, QPoint p4);
    Q_INVOKABLE void       updatePolygonINIFile();
    Q_INVOKABLE void       readPolygonINIFile();
    //rect id
    Q_INVOKABLE void       setRectIDMap(int no, int rectID);
    Q_INVOKABLE int        getRectIDMap(int no);
    Q_INVOKABLE int        getRectNoMap(int rectID);


private:
    QSettings*      m_pSettings;
    QList<QPoint>   m_listPoint;
    QMap<int, int>  m_mapRectID;

signals:
    void reloadROIInfo(QList<QString> roiList);
};

#endif // CONTROLLER_H
