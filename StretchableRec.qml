
import QtQuick 2.0

Rectangle{
    id:root
    color: "transparent"
    border.color: "#cc661a"
    border.width: 1
    property int  smallBoxHeight : 8    //小方框的高
    property int smallBoxWidth: 6       //小方框的寬
    property int startY:0               //拉伸時鼠標的起始y
    property int startX: 0              //拉伸時鼠標的起始x
    property int parentData1: 0         //用來自由儲存訊息
    property int parentData2: 0
    property bool isPressed: false      //小方框是否被點擊
    property int maxX:0                 //方框x的最大值
    property int maxY: 0                //方框y的最大值
    property int scrollNum:0            //鼠標滾輪的弧度
    Drag.active: dragMouse.drag.active  //可以拖動

    Rectangle{                  //左上小方框
        z:2
        id:leftTopRec
        color: "#303030"
        height:smallBoxHeight
        width: smallBoxWidth
        anchors.left: parent.left
        anchors.top: parent.top
        MouseArea{                      //左上小方框的鼠標區域
            id:leftTopMouse
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            onPressed: {                //點擊後記錄 鼠標被點擊 鼠標起始座標 根矩形的寬 根矩形的高
                isPressed=true
                startX=mouse.x
                startY=mouse.y
                parentData1=root.x+root.width
                parentData2=root.y+root.height
            }
            onPositionChanged: {        //鼠標移動
                if(isPressed){          //只能是在鼠標案下後拉伸
                    if(root.y+(mouse.y-startY)>=0&&root.height-(mouse.y-startY)>smallBoxHeight){ //限制拉伸的極限
                        root.y=root.y+(mouse.y-startY)
                        root.height=root.height-(mouse.y-startY)
                    }else{
                        if(root.y+(mouse.y-startY)<0){
                            root.y=0
                            root.height=parentData2
                        }
                        if(root.height-(mouse.y-startY)<smallBoxHeight)
                        {
                            root.y=parentData2-smallBoxHeight
                            root.height=smallBoxHeight
                        }
                    }
                    if(root.x+(mouse.x-startX)>=0&&root.width-(mouse.x-startX)>smallBoxWidth){
                        root.x=root.x+(mouse.x-startX)
                        root.width=root.width-(mouse.x-startX)
                    }else{
                        if(root.x+(mouse.x-startX)<0){
                            root.x=0
                            root.width=parentData1
                        }
                        if(root.width-(mouse.x-startX)<smallBoxWidth)
                        {
                            root.x=parentData1-smallBoxWidth
                            root.width=smallBoxWidth
                        }
                    }
                }
            }
            onReleased: {       //鼠標放下後將按下設置為false
                isPressed=false
            }
        }
    }
    Rectangle{              //右上小矩形
        z:2
        id:rightTopRec
        color: "#303030"
        height: smallBoxHeight
        width: smallBoxWidth
        anchors.right: parent.right
        anchors.top: parent.top
        MouseArea{          //右上矩形鼠標
            id:rightTopMouse
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            onPressed: {
                isPressed=true
                startX=mouse.x
                startY=mouse.y
                // parentData1=root.x+root.width
                parentData2=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.y+(mouse.y-startY)>=0&&root.height-(mouse.y-startY)>smallBoxHeight){
                        root.y=root.y+(mouse.y-startY)
                        root.height=root.height-(mouse.y-startY)
                    }else{
                        if(root.y+(mouse.y-startY)<0){
                            root.y=0
                            root.height=parentData2
                        }
                        if(root.height-(mouse.y-startY)<smallBoxHeight)
                        {
                            root.y=parentData2-smallBoxHeight
                            root.height=smallBoxHeight
                        }
                    }
                    if(root.width+root.x+mouse.x-startX<maxX&&root.width+mouse.x-startX>smallBoxWidth){
                        root.width=root.width+mouse.x-startX
                    }else{
                        if(root.width+root.x+mouse.x-startX>maxX)
                        {
                            root.width=maxX-root.x
                        }
                        if(root.width+mouse.x-startX<smallBoxWidth)
                        {
                            root.width=smallBoxWidth
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{             //左下矩形
        z:2
        id:leftBottomRec
        color: "#303030"
        height: smallBoxHeight
        width: smallBoxWidth
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        MouseArea{              //左下矩形的鼠標區域
            id:leftBottomMouse
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            onPressed: {
                isPressed=true
                startX=mouse.x
                startY=mouse.y
                parentData1=root.x+root.width
                //parentData2=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.x+(mouse.x-startX)>=0&&root.width-(mouse.x-startX)>smallBoxWidth){
                        root.x=root.x+(mouse.x-startX)
                        root.width=root.width-(mouse.x-startX)
                    }else{
                        if(root.x+(mouse.x-startX)<0){
                            root.x=0
                            root.width=parentData1
                        }
                        if(root.width-(mouse.x-startX)<smallBoxWidth)
                        {
                            root.x=parentData1-smallBoxWidth
                            root.width=smallBoxWidth
                        }
                    }
                    if(root.height+root.y+mouse.y-startY<maxY&&root.height+mouse.y-startY>smallBoxHeight){
                        root.height=root.height+mouse.y-startY
                    }else{
                        if(root.height+root.y+mouse.y-startY>maxY)
                        {
                            root.height=maxY-root.y
                        }
                        if(root.height+mouse.y-startY<smallBoxHeight)
                        {
                            root.height=smallBoxHeight
                        }
                    }
                }
            }

            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{
        z:2
        id:rightBottomRec
        color: "#303030"
        height:smallBoxHeight
        width:smallBoxWidth
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        MouseArea{
            id:rightBottomMouse
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            onPressed: {
                isPressed=true
                startX=mouse.x
                startY=mouse.y
                //parentData1=root.x+root.width
                //parentData2=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.width+root.x+mouse.x-startX<maxX&&root.width+mouse.x-startX>smallBoxWidth){
                        root.width=root.width+mouse.x-startX
                    }else{
                        if(root.width+root.x+mouse.x-startX>maxX)
                        {
                            root.width=maxX-root.x
                        }
                        if(root.width+mouse.x-startX<smallBoxWidth)
                        {
                            root.width=smallBoxWidth
                        }
                    }
                    if(root.height+root.y+mouse.y-startY<maxY&&root.height+mouse.y-startY>smallBoxHeight){
                        root.height=root.height+mouse.y-startY
                    }else{
                        if(root.height+root.y+mouse.y-startY>maxY)
                        {
                            root.height=maxY-root.y
                        }
                        if(root.height+mouse.y-startY<smallBoxHeight)
                        {
                            root.height=smallBoxHeight
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{
        z:2
        id:topRec
        color: "#303030"
        height:smallBoxHeight
        width:smallBoxWidth
        x:(parent.width-topRec.width)/2
        MouseArea{
            id:topMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:Qt.SizeVerCursor
            onPressed: {
                isPressed=true
                //startPoint.x=mouse.x
                startY=mouse.y
                parentData1=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.y+(mouse.y-startY)>=0&&root.height-(mouse.y-startY)>smallBoxHeight){
                        root.y=root.y+(mouse.y-startY)
                        root.height=root.height-(mouse.y-startY)
                    }else{
                        if(root.y+(mouse.y-startY)<0){
                            root.y=0
                            root.height=parentData1
                        }
                        if(root.height-(mouse.y-startY)<smallBoxHeight)
                        {
                            root.y=parentData1-smallBoxHeight
                            root.height=smallBoxHeight
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{
        z:2
        id:rightRec
        color: "#303030"
        height:smallBoxHeight
        width:smallBoxWidth
        y:(parent.height-topRec.height)/2
        anchors.right: parent.right
        MouseArea{
            id:rightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:Qt.SizeHorCursor
            onPressed: {
                isPressed=true
                startX=mouse.x
                // parentData1=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.width+root.x+mouse.x-startX<maxX&&root.width+mouse.x-startX>smallBoxWidth){
                        root.width=root.width+mouse.x-startX
                    }else{
                        if(root.width+root.x+mouse.x-startX>maxX)
                        {
                            root.width=maxX-root.x
                        }
                        if(root.width+mouse.x-startX<smallBoxWidth)
                        {
                            root.width=smallBoxWidth
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{
        z:2
        id:bottomRec
        color: "#303030"
        height:smallBoxHeight
        width:smallBoxWidth
        x:(parent.width-topRec.width)/2
        anchors.bottom: parent.bottom
        MouseArea{
            id:bottomMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:Qt.SizeVerCursor
            onPressed: {
                isPressed=true
                startY=mouse.y
                // parentData1=root.y+root.height
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.height+root.y+mouse.y-startY<maxY&&root.height+mouse.y-startY>smallBoxHeight){
                        root.height=root.height+mouse.y-startY
                    }else{
                        if(root.height+root.y+mouse.y-startY>maxY)
                        {
                            root.height=maxY-root.y
                        }
                        if(root.height+mouse.y-startY<smallBoxHeight)
                        {
                            root.height=smallBoxHeight
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{
        z:2
        id:leftRec
        color: "#303030"
        height:smallBoxHeight
        width:smallBoxWidth
        y:(parent.height-topRec.height)/2
        anchors.left: parent.left
        MouseArea{
            id:leftMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:Qt.SizeHorCursor
            onPressed: {
                isPressed=true
                startX=mouse.x
                parentData1=root.x+root.width
            }
            onPositionChanged: {
                if(isPressed){
                    if(root.x+(mouse.x-startX)>=0&&root.width-(mouse.x-startX)>smallBoxWidth){
                        root.x=root.x+(mouse.x-startX)
                        root.width=root.width-(mouse.x-startX)
                    }else{
                        if(root.x+(mouse.x-startX)<0){
                            root.x=0
                            root.width=parentData1
                        }
                        if(root.width-(mouse.x-startX)<smallBoxWidth)
                        {
                            root.x=parentData1-smallBoxWidth
                            root.width=smallBoxWidth
                        }
                    }
                }
            }
            onReleased: {
                isPressed=false
            }
        }
    }
    Rectangle{              //拖動事件，鼠標觸發區域
        id:dragArea
        anchors.fill: parent
        color: "#cc661a"
        opacity: 0.2            //透明度0.2
        MouseArea{              //鼠標區域
            id:dragMouse
            anchors.fill: parent
            cursorShape:Qt.SizeAllCursor    //鼠標樣式
            drag.target: root
            drag.minimumX: 0                //拖動區域限制
            drag.minimumY: 0
            drag.maximumX:maxX-root.width
            drag.maximumY: maxY-root.height
            onWheel: {                      //接收到滾輪事件
                scrollNum=wheel.angleDelta.y / 120      //接收滾輪滾動的大小

                if(scrollNum>0){                    //判斷棍動的方向
                    if(root.x>=5)
                    {
                        root.x-=wheel.angleDelta.y /120*5
                    }else if(0<root.x<5){               //臨界判斷
                        root.x=0
                    }

                    if(root.y>=5)
                    {
                        root.y-=wheel.angleDelta.y /120*5
                    }else if(0<root.y<5){
                        root.y=0
                    }
                    if(root.width<=maxX-root.x-10)
                    {
                        root.width+=wheel.angleDelta.y /120*5*2
                    }else if(maxX-root.x-10<root.width<maxX-root.x)
                    {
                        root.width=maxX-root.x
                    }
                    if(root.height<=maxY-root.y-10)
                    {
                        root.height+=wheel.angleDelta.y /120*5*2
                    }else if(maxY-root.y-10<=root.height<maxY-root.y)
                    {
                        root.height=maxY-root.y
                    }
                }else
                {
                    if(root.width>smallBoxWidth*3){ //限制最小的寬度不小於三個小矩形的寬
                        root.width+=wheel.angleDelta.y /120 *5*2
                        root.x-=wheel.angleDelta.y /120 *5
                    }
                    if(root.height>smallBoxHeight*3){   //限制最小的高度不小於三個小矩形的高
                        root.height+= wheel.angleDelta.y /120*5*2
                        root.y-=wheel.angleDelta.y /120 *5
                    }
                }
            }
        }
    }

}
