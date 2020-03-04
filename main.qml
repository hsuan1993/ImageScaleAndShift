import QtQuick 2.0
import QtQuick.Window 2.2

Window {
    visible: true
    width: 480
    height: 640
    title: qsTr("Image Scale & Shift")

    Rectangle {
        id: viewRec
        width: 400
        height: 600
        anchors.left: parent.left
        anchors.bottom:parent.bottom
        color: "black"
        clip: true

        Image {
            id:livePreview
            width:parent.width
            height:parent.height
            x:0
            y:0
            source: "../image/398529.jpg"
            fillMode: Image.PreserveAspectFit

            function updateDragPosition(triggerX, triggerY) {
                if ((livePreview.width) > viewRec.width || livePreview.height > viewRec.height) {
                    let xGap = (livePreview.width - livePreview.paintedWidth) / 2;
                    let yGap = (livePreview.height - livePreview.paintedHeight) / 2;
                    if (triggerX === -1) triggerX = -xGap;
                    if (triggerY === -1) triggerY = -yGap;
                    mapDragArea.drag.axis = Drag.XAndYAxis
                    mapDragArea.drag.minimumX = viewRec.width - livePreview.width + xGap;
                    mapDragArea.drag.maximumX = -xGap;
                    mapDragArea.drag.minimumY = viewRec.height - livePreview.height + yGap;
                    mapDragArea.drag.maximumY = -yGap;
                    livePreview.x = triggerX;
                    livePreview.y = triggerY;
                } else {
                    mapDragArea.drag.axis = 0
                }
            }

            MouseArea {
                id: mapDragArea
                anchors.fill: parent
                property double imgScale: 1
                onWheel: {
                    var datla = wheel.angleDelta.y/120;
                    if(datla > 0) {
                        imgScale = imgScale/0.9;
                        livePreview.width *= imgScale;
                        livePreview.height *= imgScale;
                    }
                    else {
                        if (imgScale*0.9 < 1) {
                            imgScale = 1;
                            livePreview.width = viewRec.width;
                            livePreview.height = viewRec.height;
                            livePreview.x = 0;
                            livePreview.y = 0;
                        }
                        else {
                            imgScale = imgScale *0.9;
                            livePreview.width *= imgScale;
                            livePreview.height *= imgScale;
                        }
                    }
                    if (imgScale > 1) {
                        livePreview.updateDragPosition(-1,-1);
                    }
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


