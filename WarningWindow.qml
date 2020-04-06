import QtQuick 2.8
import QtQuick.Window 2.1
import QtQuick.Controls 1.4

Window {
    id: warningWindow
    width: 460
    flags: Qt.WindowTitleHint
    //flags: Qt.FramelessWindowHint
    modality: Qt.ApplicationModal

    //To-do: Adjust height by compoment dynamic height.
    height: 200
    x: mainWindow.x + mainWindow.width / 2 - width / 2
    y: mainWindow.y + mainWindow.height / 2 - height / 2

    property alias messageTitle: title.text
    property alias messageInfo: message.text
    property alias leftBtnString: leftBtn.btnString
    property alias rightBtnString: rightBtn.btnString
    property alias leftBtnVisible: leftBtn.visible
    property alias rightBtnVisible: rightBtn.visible

    signal leftBtnClicked()
    signal rightBtnClicked()

    function setWarningType(warning_code) {
        console.log("setWarningType, code = " + warning_code);
        switch (warning_code) {
        case "ROI_DEL":
            messageTitle = qsTr("Delete the ROI?");
            messageInfo = qsTr("");
            rightBtnString = qsTr("YES(Y)");
            leftBtnString = qsTr("NO(N)");
            rightBtnVisible = true;
            leftBtnVisible = true;
            break;
        default:
            break;
        }
    }

    Shortcut {
        sequence: "Y"
        onActivated:  {
            console.log("Press YES");
            warningWindow.close();
            rightBtnClicked();
        }
    }

    Shortcut {
        sequence: "N"
        onActivated:  {
            console.log("Press NO");
            warningWindow.close();
            leftBtnClicked();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: lightGray2

        Text {
            id: title
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            text: qsTr("Warning")
            font.pixelSize: 18
            font.bold: true
            color: darkGray
        }

        Text {
            id: message
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            color: darkGray
            opacity: 0.8
        }

        // TODO: Button status
        Rectangle {
            id: rightBtn
            width: rightBtnText.paintedWidth > 100 ? (rightBtnText.paintedWidth + 20):100
            height: 30
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            color: lightBlue
            radius: 2

            property string btnString

            Text {
                id: rightBtnText
                text: rightBtn.btnString
                color:  "white"
                font.bold: true
                anchors.centerIn: rightBtn
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: rightBtn
                hoverEnabled: true

                onClicked: {
                    warningWindow.close();
                    rightBtnClicked();
                }
            }
        }

        Rectangle {
            id: leftBtn
            width: leftBtnText.paintedWidth > 100 ? (leftBtnText.paintedWidth + 20):100
            height: 30
            anchors.right: rightBtn.left
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            color: lightBlue
            radius: 2
            visible: false
            property string btnString

            Text {
                id: leftBtnText
                text: leftBtn.btnString
                color: "white"
                font.bold: true
                anchors.centerIn: leftBtn
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: leftBtn
                hoverEnabled: true

                onClicked: {
                    warningWindow.close();
                    leftBtnClicked();
                }
            }
        }
    }

    BusyIndicator {
        running: false
    }
}
