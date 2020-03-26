import QtQuick 2.0

Item {
    id: polygon4

    Connections {
        target: ctrl
        onReloadROIInfo: {
            polygonCanvas.polygonPoints = [];
            polygonCanvas.polyPointCount = 0;

            if (roiList.length > 0) {
                var pointNumber = Number(roiList[0]);
                for (var i=0; i<pointNumber; i++) {
                    var itemDetail = roiList[i+1].split(" "); //start from the second
                    var xPos = Number(itemDetail[0]);
                    var yPos = Number(itemDetail[1]);
                    polygonCanvas.polygonPoints.push({x:xPos,y:yPos});
                }
                polygonCanvas.polyPointCount = pointNumber;
            }

            //redraw rectangle
            polygonCanvas.paintType = -1;
            polygonCanvas.polygonMouseLastPointX = -1;
            polygonCanvas.polygonMouseLastPointY = -1;
            polygonSession.needClearRect = true;
            polygonSession.clearUndefined = true;
            polygonSession.requestPaint();
            polygonCanvas.bClear = true;
            polygonCanvas.bModification = false;
            polygonCanvas.requestPaint();
        }
    }

    Connections {
        target: mainWindow
        onImgScaleChanged: {
            polygonCanvas.paintType = -1;
            polygonCanvas.polygonMouseLastPointX = -1;
            polygonCanvas.polygonMouseLastPointY = -1;
            polygonSession.needClearRect = true;
            polygonSession.clearUndefined = true;
            polygonSession.requestPaint();
            polygonCanvas.bClear = true;
            polygonCanvas.bModification = false;
            polygonCanvas.requestPaint();
        }
    }

    Connections {
        target: livePreview

        onXChanged: {
            polygonCanvas.paintType = -1;
            polygonCanvas.polygonMouseLastPointX = -1;
            polygonCanvas.polygonMouseLastPointY = -1;
            polygonSession.needClearRect = true;
            polygonSession.clearUndefined = true;
            polygonSession.requestPaint();
            polygonCanvas.bClear = true;
            polygonCanvas.bModification = false;
            polygonCanvas.requestPaint();
        }
        onYChanged: {
            polygonCanvas.paintType = -1;
            polygonCanvas.polygonMouseLastPointX = -1;
            polygonCanvas.polygonMouseLastPointY = -1;
            polygonSession.needClearRect = true;
            polygonSession.clearUndefined = true;
            polygonSession.requestPaint();
            polygonCanvas.bClear = true;
            polygonCanvas.bModification = false;
            polygonCanvas.requestPaint();
        }
    }


    Canvas {
        id: polygonSession
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative
        property bool clearUndefined: false
        property bool needClearRect: false
        property string notationColor: "black"//ctrl.getSettingsValue("NOTATION_COLOR")

        onPaint: {
            var realX1 = 0;
            var realY1 = 0;
            var realX2 = 0;
            var realY2 = 0;
            var realX3 = 0;
            var realY3 = 0;
            var realX4 = 0;
            var realY4 = 0;
            var ctx = getContext("2d");
            if (needClearRect) {
                ctx.clearRect(0 , 0, width, height);
            }

            ctx.save(); //與restore相稱，沒加的話scale會累加無法還原
            ctx.scale(imgScale,imgScale);
            ctx.lineWidth = 2/imgScale;
            var undefinedNumber = (polygonCanvas.polyPointCount%4);

            if (needClearRect) {
                for (var i=0; i<polygonCanvas.polyPointCount-undefinedNumber;i++) {
                    ctx.globalCompositeOperation = "copy";
                    ctx.strokeStyle = "#ff0000";

                    ctx.beginPath();

                    realX1 = (polygonCanvas.polygonPoints[i].x -currentImgX);
                    realY1 = (polygonCanvas.polygonPoints[i].y -currentImgY) ;

                    if (i%4==3) {
                        realX2 = (polygonCanvas.polygonPoints[i-3].x -currentImgX) ;
                        realY2 = (polygonCanvas.polygonPoints[i-3].y -currentImgY) ;

                    } else {
                        realX2 = (polygonCanvas.polygonPoints[i+1].x -currentImgX) ;
                        realY2 = (polygonCanvas.polygonPoints[i+1].y -currentImgY) ;
                    }

                    ctx.moveTo(realX1, realY1);
                    ctx.lineTo(realX2, realY2);
                    ctx.stroke();

                    if (i%4==3) { //show rect id
                        ctx.fillStyle = notationColor;
                        var fontPixelSize = 20 / imgScale;
                        ctx.font = fontPixelSize + "px 'Calibri light'";
                        ctx.fillText(ctrl.getRectIDMap((Math.floor(i/4))).toString(), (realX1 + realX2)/2 , (realY1 + realY2)/2);
                    }
                }
            }

            if (clearUndefined) {
                if (!needClearRect) {
                    for (i=0; i<undefinedNumber-1;i++) {
                        ctx.globalCompositeOperation = "xor";
                        ctx.beginPath();
                        realX1 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1-i].x -currentImgX;
                        realY1 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1-i].y -currentImgY;

                        realX2 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2-i].x -currentImgX;
                        realY2 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2-i].y -currentImgY;

                        ctx.moveTo(realX1, realY1);
                        ctx.lineTo(realX2, realY2);
                        ctx.stroke();
                    }
                }
                polygonCanvas.polyPointCount =  polygonCanvas.polyPointCount - undefinedNumber;
                for (var j=0;j<undefinedNumber;j++){
                    polygonCanvas.polygonPoints.splice(polygonCanvas.polygonPoints.length-1, 1);
                }
            }

            if (polygonCanvas.paintType == 0) {
                console.log("paint type == 0")
                ctx.globalCompositeOperation = "copy";
                ctx.strokeStyle = "#ff0000";
                ctx.beginPath();
                realX1 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2].x -currentImgX;
                realY1 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2].y -currentImgY;
                realX2 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1].x -currentImgX;
                realY2 = polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1].y -currentImgY;
                ctx.moveTo(realX1, realY1);
                ctx.lineTo(realX2, realY2);
                ctx.stroke();
            }

            clearUndefined = false;
            needClearRect = false;
            ctx.restore();
            gc();
        }
    }

    Canvas {
        id: polygonCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative

        property int   limitLx: 0
        property int   limitLy: 0
        property int   limitRx: livePreview.width < width ? livePreview.width : width
        property int   limitRy: livePreview.height < height ? livePreview.height : height
        property bool  bModification: false //modify polygon

        property var polygonPoints: [] //array{x,y}
        property int polygonMousePointX: 0
        property int polygonMousePointY: 0
        property int polyPointCount: 0

        property int   currentRegionNumber: 0 //rect id

        property bool  bClear: false
        property int polygonMouseLastPointX: -1
        property int polygonMouseLastPointY: -1
        property int paintType: -1

        property bool  bRedrawMask: false

        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#ff0000";
            ctx.lineWidth = 1;
            var realX0 = 0;
            var realY0 = 0;
            var realX1 = 0;
            var realY1 = 0;
            var realX2 = 0;
            var realY2 = 0;
            var realX3 = 0;
            var realY3 = 0;
            var realX4 = 0;
            var realY4 = 0;
            if (bClear) {
                 ctx.clearRect(0 , 0, polygonCanvas.width,  polygonCanvas.height);
            }

            if (paintType == 0) {
                // Reserved
            }else if (paintType == 1) { //when mouse moving, paint line.
                if (polygonCanvas.polyPointCount%4 == 3) {
                    realX0 = (polygonPoints[polyPointCount-3].x -currentImgX) *imgScale;
                    realY0 = (polygonPoints[polyPointCount-3].y -currentImgY) *imgScale;
                }

                realX1 = (polygonPoints[polyPointCount-1].x -currentImgX) *imgScale;
                realY1 = (polygonPoints[polyPointCount-1].y -currentImgY) *imgScale;

                realX2 = (polygonMouseLastPointX -currentImgX) *imgScale;
                realY2 = (polygonMouseLastPointY -currentImgY) *imgScale;

                if (polygonMouseLastPointX != -1 && polygonMouseLastPointY!=-1) {
                    if (polygonCanvas.polyPointCount%4 == 3) {
                        ctx.clearRect(0 , 0, polygonCanvas.width,  polygonCanvas.height);
                    } else {
                        ctx.globalCompositeOperation = "xor";
                        ctx.beginPath();
                        ctx.moveTo(realX1, realY1);
                        ctx.lineTo(realX2, realY2);
                        ctx.stroke();
                    }
                }

                realX3 = (polygonMousePointX -currentImgX) *imgScale;
                realY3 = (polygonMousePointY -currentImgY) *imgScale;
                ctx.globalCompositeOperation = "copy";
                ctx.beginPath();
                ctx.moveTo(realX1, realY1);
                ctx.lineTo(realX3, realY3);
                ctx.stroke();

                if (polygonCanvas.polyPointCount%4 == 3) {
                    ctx.beginPath();
                    ctx.moveTo(realX0, realY0);
                    ctx.lineTo(realX3, realY3);
                    ctx.stroke();
                }

                polygonMouseLastPointX =  polygonMousePointX;
                polygonMouseLastPointY =  polygonMousePointY;

            }else if (paintType == 2) {
                // Reserved
            }else if (paintType == 3) {
                //
            }else if (paintType == 4) { //when fourth time click image
                bRedrawMask = true;
                realX1 = polygonPoints[polygonPoints.length-4].x ;
                realY1 = polygonPoints[polygonPoints.length-4].y ;

                realX4 = polygonPoints[polygonPoints.length-1].x ;
                realY4 = polygonPoints[polygonPoints.length-1].y ;

                realX2 = polygonPoints[polygonPoints.length-3].x ;
                realY2 = polygonPoints[polygonPoints.length-3].y ;

                realX3 = polygonPoints[polygonPoints.length-2].x ;
                realY3 = polygonPoints[polygonPoints.length-2].y ;

//                roiDetail.addROI({NumberID:ctrl.getRectIDMap(ploygonCanvas.currentRegionNumber), metaName:currentSelectedMeta, paintColor: currentPaintColor, roiInfo:stringInfo, canBeUsed:true});

                polygonSession.needClearRect = true;
                polygonSession.clearUndefined = false;
                polygonSession.requestPaint();
                polygonCanvas.paintType = -1;
                polygonCanvas.bClear = true;
                polygonCanvas.requestPaint();
                return;

            }

            paintType= -1;
            polygonCanvas.bClear = false;
        }

        MouseArea {
            id: polygonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed:  {
                if (!bCanDrawZone)
                    return;

                if (mouse.button === Qt.LeftButton) {
                    //bStartDrawZone = true;
                    console.log("left button")
                    if ( mouse.x > polygonCanvas.limitLx && mouse.y > polygonCanvas.limitLy
                        && mouse.x < polygonCanvas.limitRx && mouse.y < polygonCanvas.limitRy) {
                        if (polygonCanvas.bModification)
                            return;

                        var realX = Math.floor((mouse.x / imgScale) + currentImgX);
                        var realY = Math.floor((mouse.y / imgScale) + currentImgY);
                        polygonCanvas.polygonMousePointX = realX;
                        polygonCanvas.polygonMousePointY = realY;
                        polygonCanvas.polygonPoints.push({x: realX , y: realY});
                        polygonCanvas.polyPointCount++;
                        if (polygonCanvas.polyPointCount>=2 && (polygonCanvas.polyPointCount%4)!=1) {
                            if(polygonCanvas.polyPointCount%4 == 0){ //fourth time
                                // rect id
                                polygonCanvas.currentRegionNumber = (polygonCanvas.polyPointCount/4) -1;
                                var targetID = ploygonCanvas.polyPointCount/4;
                                // show text input window
                                //var targetID  = ctrl.showInputRectNumberDialog(polygonCanvas.polyPointCount/4);
                                //if (targetID < 0) {
                                //    targetID = polygonCanvas.currentRegionNumber;
                                //}
                                // check rectangle id conflict
                                while (ctrl.getRectNoMap(targetID)!== -1) {
                                    console.log("Rect ID conflict: "+targetID);
                                    targetID++;
                                }
                                ctrl.setRectIDMap(polygonCanvas.currentRegionNumber, targetID);
                                polygonCanvas.polygonMouseLastPointX = -1;
                                polygonCanvas.polygonMouseLastPointY = -1;
                                polygonCanvas.bClear = true;
                                polygonCanvas.paintType = 4;
                                polygonCanvas.requestPaint();
                                //update points
                                ctrl.addPolygon4(Qt.point(polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-4].x, polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-4].y),
                                                 Qt.point(polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-3].x, polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-3].y),
                                                 Qt.point(polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2].x, polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-2].y),
                                                 Qt.point(polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1].x, polygonCanvas.polygonPoints[polygonCanvas.polyPointCount-1].y)
                                                 );
                            }
                            else {
                                polygonCanvas.paintType = 0;
                                polygonSession.requestPaint(); //draw line
                            }
                        }
                    }

                }
                else if (mouse.button === Qt.RightButton){
                    console.log("right button")
                }

                polygonMouseArea.cursorShape = Qt.ArrowCursor;
            }
            onPositionChanged: {
                if (!bCanDrawZone)
                    return;

                if ( mouse.x > polygonCanvas.limitLx && mouse.y > polygonCanvas.limitLy
                    && mouse.x < polygonCanvas.limitRx && mouse.y < polygonCanvas.limitRy) {

                    var realX = Math.floor((mouse.x / imgScale) + currentImgX);
                    var realY = Math.floor((mouse.y / imgScale) + currentImgY);

                    //draw line(move)
                    if (polygonCanvas.polyPointCount>=1 && (polygonCanvas.polyPointCount%4)!=0){
                        polygonCanvas.polygonMousePointX = realX;
                        polygonCanvas.polygonMousePointY = realY;
                        polygonCanvas.paintType = 1;
                        polygonCanvas.requestPaint();
                    } else {
                        polygonCanvas.polygonMouseLastPointX = -1;
                        polygonCanvas.polygonMouseLastPointY = -1;
                    }

                }


            }
        }
    }

}
