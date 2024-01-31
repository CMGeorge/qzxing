import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtMultimedia

import QZXing 3.3

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
    Component{
        id: cameraComponent
        Camera{
            id:camera
            active: true
            //        active: Application.state===Qt.ApplicationActive
            focusMode: Camera.FocusModeAutoNear
        }
    }
    Component{
        id: newVideoOutput
        VideoOutput{

            anchors.fill: parent
        }
    }

    CaptureSession {
        id: captureSession
        //        camera: camera
        videoOutput: componentLoader.item//videoOutput
    }
    //    Component{
    //        id: videoOutput
    //        VideoOutput{
    //            //            id: videoOutput
    //            anchors.fill: parent
    //        }
    //    }

    Rectangle{
        //video area
        id: videoOutputArea
        property double captureRectStartFactorX: 0.25
        property double captureRectStartFactorY: 0.25
        property double captureRectFactorWidth: 0.5
        property double captureRectFactorHeight: 0.5
        color: "black"
        anchors.top: text1.bottom
        anchors.bottom: text2.top
        anchors.left: parent.left
        anchors.right: parent.right
//        VideoOutput{
//            id: videoOutput
//            anchors.fill: parent
//        }
                Loader{
                    id: componentLoader
                    anchors.fill: parent
//                    sourceComponent: Application.state===Qt.ApplicationActive ? videoOutput : null
                    onLoaded: {
                        console.debug("Loaded Item: ",componentLoader.item)
//                        camera.start();
                    }
                }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                captureSession.camera.customFocusPoint = Qt.point(mouseX / width,  mouseY / height);
                captureSession.camera.focusMode = Camera.FocusModeManual;
                captureSession.camera.start();
                zxingFilter.videoSink = captureSession.videoOutput.videoSink

            }
        }

        Rectangle {
            id: captureZone
            color: "red"
            opacity: 0.2
            width: parent.width * parent.captureRectFactorWidth
            height: parent.height * parent.captureRectFactorHeight
            x: parent.width * parent.captureRectStartFactorX
            y: parent.height * parent.captureRectStartFactorY
        }

    }

    //    VideoOutput
    //    {
    //        id: videoOutput

    //        //        fillMode: VideoOutput.





    //        //         Component.onCompleted: { camera.active = false; camera.active = true; }
    //    }
    Connections{
        target: Application
        function onStateChanged(newState){
            switch (newState){
            case Qt.ApplicationActive: {
                console.debug("Appliciton is activating.. can do some things hrer...")
                attacheCamera();

                break;
            }
            default:{
                console.info("Switching to state ",newState)
                if (captureSession.camera){
                    console.error("Cleaning up camera");
                    captureSession.camera.stop();
                    delete captureSession.camera
                    captureSession.camera=null
                    zxingFilter.videoSink = null
                    zxingFilter.videoSink.deleteLater();
                    //                    zxingFilter.videoSink = null
                }
            }
            }
        }
    }
    Component.onCompleted: {
        attacheCamera();
    }

    function attacheCamera(){
        if (!captureSession.camera){
            captureSession.camera = cameraComponent.createObject(captureSession.camera);
            componentLoader.sourceComponent = newVideoOutput
        }
    }

    //    component VideSink:
    QZXingFilter
    {
        id: zxingFilter
        //        videoSink: captureSession.videoOutput?captureSession.videoOutput.videoSink:null
        //        videoSink: Application.state === Qt.ApplicationActive?videoOutput.videoSink:null
        //        orientation: videoOutput.orientation

        captureRect: {
//            videoOutput.sourceRect;
            return captureSession.videoOutput
                    ?Qt.rect(captureSession.videoOutput.sourceRect.width,// * videoOutput.captureRectStartFactorX,
                             captureSession.videoOutput.sourceRect.height,// * videoOutput.captureRectStartFactorY,
                             captureSession.videoOutput.sourceRect.width,// * videoOutput.captureRectFactorWidth,
                             captureSession.videoOutput.sourceRect.height// * videoOutput.captureRectFactorHeight
                             )
                    :Qt.rect(0,0,0,0);
        }

        decoder {
            enabledDecoders: /*QZXing.DecoderFormat_EAN_13 | QZXing.DecoderFormat_CODE_39 | */QZXing.DecoderFormat_QR_CODE

            onTagFound: {
                console.log(tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet());

                window.detectedTags++;
                window.lastTag = tag;
            }

            tryHarder: true
        }

        onDecodingStarted:
        {
            //            console.log("started");
        }

        property int framesDecoded: 0
        property real timePerFrameDecode: 0

        onDecodingFinished:
        {
            timePerFrameDecode = (decodeTime + framesDecoded * timePerFrameDecode) / (framesDecoded + 1);
            framesDecoded++;
            if(succeeded)
                console.log("frame finished: " + succeeded, decodeTime, timePerFrameDecode, framesDecoded);
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
}
