import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtMultimedia



ApplicationWindow
{
    id: window
    visible: true
    width: 640
    height: 480
    title: "Qt QZXing Filter Test"

    property int detectedTags: 0
    property string lastTag: ""

    Rectangle
    {
        id: bgRect
        color: "white"
        anchors.fill: videoOutputArea
    }

    Text
    {
        id: text1
        wrapMode: Text.Wrap
        font.pixelSize: 20
        anchors.top: parent.top
        anchors.left: parent.left
        z: 50
        text: "Tags detected: " + detectedTags
    }
    Text
    {
        id: fps
        font.pixelSize: 20
        anchors.top: parent.top
        anchors.right: parent.right
        z: 50
        text: (1000 / zxingFilter.timePerFrameDecode).toFixed(0) + "fps"
    }

    //    Component{
    //        id: videoOutput
    //        VideoOutput{
    //            //            id: videoOutput
    //            anchors.fill: parent
    //        }
    //    }
//    Component{
//        id: videoOutputArea
//        Qt65CameraController{
//            //video area
//        }
//    }
    Loader{
        id: camLoader;
        anchors.top: text1.bottom
        anchors.bottom: text2.top
        anchors.left: parent.left
        anchors.right: parent.right
        //        sourceComponent: Application.state===Qt.ApplicationActive ? videoOutputArea : null
        onLoaded: {
            console.debug("Loaded Item: ",item)
            delayCameraStart.start();
//            item.camera.start();
            //                        camera.start();
        }
    }
    function attacheCamera(){
        if (!camLoader.item){
            console.info("Create new camera view")
//            camLoader.sourceComponent = videoOutputArea
            camLoader.setSource("Qt65CameraController.qml");
            //            componentLoader.sourceComponent = newVideoOutput
        }
    }
    Connections{
        target: Application
        function onStateChanged(newState){
            switch (newState){
            case Qt.ApplicationActive: {
                if (!camLoader.item){
                    console.debug("Appliciton is activating.. can do some things hrer...")
                    attacheCamera();
                }

                break;
            }
            default:{
                console.info("Switching to state ",newState)
                if (camLoader.item){
                    camLoader.item.camera.stop();
                    console.debug("Dleting camare informations")
                    delete camLoader.item;
                    camLoader.sourceComponent = null
                    camLoader.setSource("");
                }
                //                if (captureSession.camera){
                //                    console.error("Cleaning up camera");
                //                    captureSession.camera.stop();
                //                    delete captureSession.camera
                //                    captureSession.camera=null
                //                    zxingFilter.videoSink = null
                //                    zxingFilter.videoSink.deleteLater();
                //                    //                    zxingFilter.videoSink = null
                //                }
            }
            }
        }
    }

    Text
    {
        id: text2
        wrapMode: Text.Wrap
        font.pixelSize: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        z: 50
        text: "Last tag: " + lastTag
    }
    Switch {
        text: "Autofocus"
        checked: captureSession.camera.focusMode === Camera.FocusModeAutoNear
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        onCheckedChanged: {
            if (checked) {
                captureSession.camera.focusMode = Camera.FocusModeAutoNear
            } else {
                captureSession.camera.focusMode = Camera.FocusModeManual
                captureSession.camera.customFocusPoint = Qt.point(0.5,  0.5)
            }
        }
        font.family: Qt.platform.os === 'android' ? 'Droid Sans Mono' : 'Monospace'
        font.pixelSize: Screen.pixelDensity * 5
    }
    Timer{
       id: delayCameraStart
       interval: 2000
       repeat: false
       onTriggered: {
           console.debug("Delat triggered")
           camLoader.item.camera.start()
       }
    }

}
