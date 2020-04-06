import QtQuick 2.0

Item {
    id: polygon4
    property int  rectIndex: -1

    function redrawRect() {
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
            redrawRect();
        }
    }

    Connections {
        target: roiDetail

        onRoiSelected: {
            rectIndex = roiIndex;
            if (bModify) {
                polygonCanvas.modifyPolygon(roiIndex);
                polygonCanvas.requestPaint();
            }
        }

        onRoiUnselected: {
            redrawRect();
        }
    }

    Connections {
        target: mainWindow
        onImgScaleChanged: {
            redrawRect();
        }
        onClearROISelected: {
            ctrl.disablePolygon4(rectIndex);
            polygonCanvas.polygonPoints[rectIndex*4].x =0;
            polygonCanvas.polygonPoints[rectIndex*4].y =0;
            polygonCanvas.polygonPoints[rectIndex*4+1].x =0;
            polygonCanvas.polygonPoints[rectIndex*4+1].y =0;
            polygonCanvas.polygonPoints[rectIndex*4+2].x =0;
            polygonCanvas.polygonPoints[rectIndex*4+2].y =0;
            polygonCanvas.polygonPoints[rectIndex*4+3].x =0;
            polygonCanvas.polygonPoints[rectIndex*4+3].y =0;
            polygonCanvas.bRedrawMask = true;
            redrawRect();
        }
    }

    Connections {
        target: livePreview
        onXChanged: {
            redrawRect();
        }
        onYChanged: {
            redrawRect();
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
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop("0", "green");
            gradient.addColorStop("0.5", "Orange");
            gradient.addColorStop("0.6", "red");
            var undefinedNumber = (polygonCanvas.polyPointCount%4);

            if (needClearRect) {
                for (var i=0; i<polygonCanvas.polyPointCount-undefinedNumber;i++) {
                    ctx.globalCompositeOperation = "copy";
                    // Fill with gradient
                    ctx.strokeStyle = gradient;
                    //ctx.strokeStyle = "#ff0000";

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
                if (polygonCanvas.bRedrawMask) {
                    ctrl.updatePolygonINIFile();
                    polygonCanvas.bRedrawMask = false;
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

                // Fill with gradient
                ctx.strokeStyle = gradient;
                //ctx.strokeStyle = "#ff0000";
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
        property int   resizeBoxSize: 5

        property var selectedPolygonPoints: [] //for modification
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

        function modifyPolygon(index) {
            console.log("modifyPolygon index: "+index);
            polygonCanvas.bClear = true;
            polygonCanvas.bModification = true;
            rectIndex = index;
            polygonCanvas.selectedPolygonPoints = [];
            polygonCanvas.selectedPolygonPoints.push({x: polygonCanvas.polygonPoints[rectIndex*4].x, y: polygonCanvas.polygonPoints[rectIndex*4].y});
            polygonCanvas.selectedPolygonPoints.push({x: polygonCanvas.polygonPoints[rectIndex*4+1].x, y: polygonCanvas.polygonPoints[rectIndex*4+1].y});
            polygonCanvas.selectedPolygonPoints.push({x: polygonCanvas.polygonPoints[rectIndex*4+2].x, y: polygonCanvas.polygonPoints[rectIndex*4+2].y});
            polygonCanvas.selectedPolygonPoints.push({x: polygonCanvas.polygonPoints[rectIndex*4+3].x, y: polygonCanvas.polygonPoints[rectIndex*4+3].y});
        }

        onPaint: {
            var ctx = getContext("2d");
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop("0", "green");
            gradient.addColorStop("0.5", "Orange");
            gradient.addColorStop("0.6", "red");

            // Fill with gradient
            ctx.strokeStyle = gradient;
            //ctx.strokeStyle = "#ff0000";
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

                roiDetail.addROI({NumberID:ctrl.getRectIDMap(polygonCanvas.currentRegionNumber)});

                polygonSession.needClearRect = true;
                polygonSession.clearUndefined = false;
                polygonSession.requestPaint();
                polygonCanvas.paintType = -1;
                polygonCanvas.bClear = true;
                polygonCanvas.requestPaint();
                return;

            }

            if (bModification) {
                bRedrawMask = true;
                ctx.globalCompositeOperation = "copy";
                ctx.lineWidth = 1;

                // Fill with gradient
                ctx.strokeStyle = gradient;
                //ctx.fillStyle = "#efff0000";
                for (var k=0;k<4;k++) {
                    var pointX0 = (selectedPolygonPoints[k].x-currentImgX) * imgScale;
                    var pointY0 = (selectedPolygonPoints[k].y-currentImgY) * imgScale;
                    var pointX1 = (selectedPolygonPoints[(k+1)%4].x-currentImgX) * imgScale;
                    var pointY1 = (selectedPolygonPoints[(k+1)%4].y-currentImgY) * imgScale;
                    ctx.beginPath();
                    ctx.moveTo(pointX0, pointY0);
                    ctx.lineTo(pointX1, pointY1);
                    ctx.stroke();
                }

                // Fill with gradient
                ctx.strokeStyle = gradient;
                ctx.fillStyle = "#efffff00";
                for (var l=0;l<4;l++) {
                    var pivotX0 = (selectedPolygonPoints[l].x-currentImgX) * imgScale;
                    var pivotY0 = (selectedPolygonPoints[l].y-currentImgY) * imgScale;
                    ctx.fillRect(pivotX0-resizeBoxSize, pivotY0-resizeBoxSize, resizeBoxSize*2, resizeBoxSize*2);
                }
            }

            paintType= -1;
            polygonCanvas.bClear = false;
        }

        MouseArea {
            id: polygonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property int selectedPivot : -1
            function determineAdjustPivote(X, Y) {
                for (var i=0; i<4;i++) {
                    var x0 = (polygonCanvas.selectedPolygonPoints[i].x-currentImgX) * imgScale;
                    var y0 = (polygonCanvas.selectedPolygonPoints[i].y-currentImgY) * imgScale;

                    if (X<=x0+polygonCanvas.resizeBoxSize && X>=x0-polygonCanvas.resizeBoxSize && Y<=y0+polygonCanvas.resizeBoxSize && Y>=y0-polygonCanvas.resizeBoxSize) {
                        return i;
                    }
                }
                return -1;
            }

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
                                var targetID = polygonCanvas.polyPointCount/4;
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
                    if (polygonCanvas.bModification) {
                        for (var k=0;k<4;k++) {
                            polygonCanvas.polygonPoints[rectIndex*4+k].x =  polygonCanvas.selectedPolygonPoints[k].x;
                            polygonCanvas.polygonPoints[rectIndex*4+k].y =  polygonCanvas.selectedPolygonPoints[k].y;
                            ctrl.modifyPolygon4(rectIndex, k, Qt.point(polygonCanvas.selectedPolygonPoints[k].x, polygonCanvas.selectedPolygonPoints[k].y));
                        }

                        polygonCanvas.bModification = false;
                        polygonCanvas.bClear = true;
                        polygonCanvas.requestPaint();
                        polygonSession.needClearRect = true;
                        polygonSession.clearUndefined = false;
                        polygonSession.requestPaint();
                        roiDetail.cancelROISelected();
                    }
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

                if (polygonCanvas.bModification) {
                    if (polygonMouseArea.containsPress) {
                        if (selectedPivot >=0) {
                            polygonMouseArea.cursorShape = Qt.SizeAllCursor;
                            polygonCanvas.selectedPolygonPoints[selectedPivot].x = realX;
                            polygonCanvas.selectedPolygonPoints[selectedPivot].y = realY;
                            polygonCanvas.bClear = true;
                            polygonCanvas.requestPaint();
                        }
                    } else {
                        selectedPivot = determineAdjustPivote(mouse.x, mouse.y);
                        polygonMouseArea.cursorShape = selectedPivot>=0 ? Qt.SizeAllCursor: Qt.ArrowCursor;
                    }
                } else {
                        polygonMouseArea.cursorShape = Qt.ArrowCursor;
                        selectedPivot = -1;
                    }

            }
        }
    }

}
