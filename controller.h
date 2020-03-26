#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QQmlContext>
#include <QPoint>

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QQmlContext *context);
    virtual ~Controller();

    Q_INVOKABLE void  addPolygon4(QPoint p1, QPoint p2, QPoint p3, QPoint p4);

private:
    QList<QPoint> m_listPoint;
};

#endif // CONTROLLER_H
