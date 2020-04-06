import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id:roiDetail

    property color  gray4:        "#444444"
    property color  gray2:        "#2F2F2F"

    signal roiSelected(var roiIndex, var bModify)
    signal roiUnselected()

    function addROI(roiElement) {
        roiBlockModel.append(roiElement);
    }
    function cancelROISelected() {
        roiGridView.currentIndex = -1;
    }

    Connections {
        target: mainWindow
        onClearROISelected: {
            if (roiGridView.currentIndex >=0 & roiGridView.currentIndex < roiBlockModel.count) {
                roiBlockModel.remove(roiGridView.currentIndex);
                roiGridView.currentIndex = -1;
            }
        }
        onCancelROISelected:{
           roiGridView.currentIndex = -1;
           roiDetail.roiUnselected();
        }
    }

    Connections {
        target: ctrl
        onReloadROIInfo: {
            console.log("ROIDetail ROI List count: "+ roiList.length);
            roiBlockModel.clear();

            if (roiList.length > 0) {
                var pointNumber = Number(roiList[0]);
                //var rectNumber = pointNumber/4;
                for (var i=0; i<pointNumber; i+=4) {
                    var posNotEnpty = 0;
                    for(var j=0;j<4;j++){
                        var itemDetail = roiList[i+1+j].split(" "); //start from the second
                        var xPos = Number(itemDetail[0]);
                        var yPos = Number(itemDetail[1]);
                        if(xPos===0&&yPos===0){
                            posNotEnpty++;
                        }
                    }
                    if(posNotEnpty<4){
                        var rectItem = {"NumberID":ctrl.getRectIDMap(i/4)};
                       roiBlockModel.append(rectItem);
                    }
                }
            }
            roiGridView.currentIndex = -1;
        }
    }

    ScrollView {
        id: scroll
        anchors.fill: parent

        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Delete ) {
                //delete polygon
                if (roiGridView.currentIndex >=0) {
                    warningCode = "ROI_DEL";
                    showWarningWindow("ROI_DEL");
                    event.accepted = true;
                }
            } else {
                //unselect polygon
                event.accepted = true;
                roiGridView.currentIndex = -1;
                roiDetail.roiUnselected();
            }
        }

        style: ScrollViewStyle {
            handle: Rectangle {
                implicitWidth: 5
                implicitHeight: 20
                color: lightBlue//gray4
            }
            scrollBarBackground: Rectangle {
                implicitWidth: 5
                implicitHeight: parent.height
                color: gray2
            }
            decrementControl: Rectangle {
                implicitWidth: 5
                color: "transparent"
            }
            incrementControl: Rectangle {
                implicitWidth: 5
                color: "transparent"
            }
        }

        GridView {
            id: roiGridView
            anchors.fill: parent
            snapMode :  GridView.NoSnap
            cellWidth: roiGridView.width
            cellHeight: 50
            highlightFollowsCurrentItem: true
            currentIndex: -1

            model: ListModel { id: roiBlockModel }

            delegate: Item {
                id: roiDelegate
                width: roiGridView.cellWidth
                height: roiGridView.cellHeight

                Rectangle {
                    id: roiRectInfo
                    anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: 1
                    color: darkGray
                    border.color:  roiGridView.currentIndex == index ? lightBlue : darkGray
                    border.width:2
                    visible:  true

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Current roiGridView index: "+ index);
                            roiGridView.currentIndex = index;
                            var realIndex = ctrl.getRectNoMap(roiBlockModel.get(roiGridView.currentIndex).NumberID);
                            console.log("Current rect id=",realIndex);
                            roiSelected(realIndex, true);
                        }
                    }

                    Text {
                        id: cellROITextInfo
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        anchors.fill: parent
                        anchors.leftMargin: 25
                        text: NumberID
                        font.pixelSize: 10
                        font.bold: false
                        color: "black"
                        wrapMode: Text.WordWrap
                    }
                }
            }

        }
    }

}
