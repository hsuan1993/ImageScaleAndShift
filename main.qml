import QtQuick 2.0
import QtQuick.Window 2.2

Window {
    id: mainWindow
    visible: true
    width: 800*2
    height: 700
    title: qsTr("Image Scale & Shift")
    property string yuanGreen: "#98c135"
    property double imgScale: 1
    property bool bCanDrawZone: false
    property var currentImgX: 0
    property var currentImgY: 0

    //method 1
    Rectangle{
        id:container
        height: 200
        width: 200
        border.color:"#008792"
        border.width:1
        x:420
        y:400
        StretchableRec{ //自定義的可拉伸矩形
             id:testRec1
             height: 50
             width: 50
             x:20
             y:20
             maxY: parent.height
             maxX: parent.width
        }
    }
    Flickable {
       id:flick
        width: 400; height: 400
        clip: true
        interactive:false //flickable不可拂動(如果不加這句，點擊flickable任意位置content會回到(0,0)座標)
        Rectangle{        //需要顯示的內容
            id:myContent
            height:(200/testRec1.height)*flick.height
            width: (200/testRec1.width)*flick.width
            Image {       //這裡顯示一張圖片
                id: img
                source: "../image/398529.jpg"
                anchors.fill:parent
            }
        }
        //使顯示的座標與拖動handle在對應框中的座標相應
        contentX: (myContent.width/200)*testRec1.x
        contentY:(myContent.height/200)*testRec1.y
    }

    //draw zone button
    Rectangle {
        id: rectAILableing
        anchors.top: parent.top; anchors.topMargin: 10; anchors.right: parent.right; anchors.rightMargin: 10
        height: 30 ; width: 120 ; color: "transparent"; border.width: 1;
        border.color: maAILableing.containsMouse? yuanGreen : (bCanDrawZone?yuanGreen:"black")
        Text {
            anchors.centerIn: parent
            font.pixelSize: Math.floor(parent.height *0.6)
            color: maAILableing.containsMouse? yuanGreen : (bCanDrawZone?yuanGreen:"black")
            text: "Draw Zone"
        }
        MouseArea {
            id: maAILableing
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                bCanDrawZone = !bCanDrawZone;
            }
        }
    }

    //method 2
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: rectPreview.top
        anchors.bottomMargin: 10
        color: "black"
        text: Math.round(imgScale*100)+"%"
    }

    Rectangle {
        id: rectPreview
        width: viewRec.width*0.5
        height: viewRec.height*0.5
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: viewRec.bottom
        color: "black"
        Image {
            anchors.fill: parent
            source: livePreview.source
        }

        Rectangle {
            id: view
            width: parent.width
            height: parent.height
            color: "gray"
            opacity: 0.5
//            border.color: "gainsboro"
//            border.width: 3
            x:0
            y:0
        }
    }

    Rectangle {
        id: viewRec
        width: 400
        height: 600
        //anchors.left: parent.left
        //anchors.leftMargin: 10
        x:800
        anchors.verticalCenter:  parent.verticalCenter
        color: "black"
        clip: true

        Polygon4 {
            id: polygon4
            anchors.fill: parent //viewRec
            enabled: bCanDrawZone?true:false
            z: 10
            Component.onCompleted: {
                ctrl.readPolygonINIFile();
            }
        }

        Image {
            id:livePreview
            width:parent.width
            height:parent.height
            x:0
            y:0
            source: "../image/398529.jpg"
            //fillMode: Image.PreserveAspectFit

            function updateDragPosition(triggerX, triggerY) {
                if ((livePreview.width) > viewRec.width || livePreview.height > viewRec.height) {
//                    let xGap = (livePreview.width - livePreview.paintedWidth) / 2;
//                    let yGap = (livePreview.height - livePreview.paintedHeight) / 2;
//                    if (triggerX === -1) triggerX = -xGap;
//                    if (triggerY === -1) triggerY = -yGap;
                    var xGap = 0;
                    var yGap = 0;
                    mapDragArea.drag.axis = Drag.XAndYAxis
                    mapDragArea.drag.minimumX = viewRec.width - livePreview.width + xGap;
                    mapDragArea.drag.maximumX = -xGap;
                    mapDragArea.drag.minimumY = viewRec.height - livePreview.height + yGap;
                    mapDragArea.drag.maximumY = -yGap;
//                    livePreview.x = triggerX;
//                    livePreview.y = triggerY;
                    livePreview.x = xGap;
                    livePreview.y = yGap;
                } else {
                    mapDragArea.drag.axis = 0
                }
            }

            onXChanged: {
                var XGap = livePreview.x / ((rectPreview.width/view.width)*viewRec.width/rectPreview.width);
                view.x = -XGap;
                currentImgX = -livePreview.x /imgScale;
            }
            onYChanged: {
                var YGap = livePreview.y / ((rectPreview.height/view.height)*viewRec.height/rectPreview.height)
                view.y = -YGap;
                currentImgY = -livePreview.y /imgScale;
            }

            MouseArea {
                id: mapDragArea
                anchors.fill: parent
                enabled: bCanDrawZone?false:true


                onWheel: {
                    var datla = wheel.angleDelta.y/120;
                    if(datla > 0) {
                        imgScale = imgScale/0.9;
                        livePreview.width /= 0.9;
                        livePreview.height /= 0.9;

                        view.width *= 0.9;
                        view.height *= 0.9;
                    }
                    else {
                        if (imgScale*0.9 < 1) {
                            imgScale = 1;
                            livePreview.width = viewRec.width;
                            livePreview.height = viewRec.height;
                            livePreview.x = 0;
                            livePreview.y = 0;

                            view.width = rectPreview.width;
                            view.height = rectPreview.height;
                            view.x = 0;
                            view.y = 0;
                        }
                        else {
                            imgScale = imgScale *0.9;
                            livePreview.width *= 0.9;
                            livePreview.height *= 0.9;

                            view.width /= 0.9;
                            view.height /= 0.9;
                        }
                    }
                    livePreview.updateDragPosition(-1,-1);
                }

                drag.target: livePreview
                drag.maximumX: 0
                drag.maximumY: 0
                drag.minimumX: 0
                drag.minimumY: 0
            }
        }



    }
}


