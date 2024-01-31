import QtQuick
import QtMultimedia
import QZXing
Rectangle {
    color: "black"
    property alias camera:captureSession.camera

    property double captureRectStartFactorX: 0.25
    property double captureRectStartFactorY: 0.25
    property double captureRectFactorWidth: 0.5
    property double captureRectFactorHeight: 0.5
    CaptureSession {
        id: captureSession
        camera: Camera{
            id:camera
            active: false
            focusMode: Camera.FocusModeAutoNear
        }
        videoOutput: videoOutput
    }

    VideoOutput{
        id: videoOutput
        property double captureRectStartFactorX: 0.25
        property double captureRectStartFactorY: 0.25
        property double captureRectFactorWidth: 0.5
        property double captureRectFactorHeight: 0.5
        anchors.fill: parent

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
    QZXingFilter
    {
        id: zxingFilter
//        videoSink: videoOutput.videoSinkzxingFilter
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
    Component.onDestruction: {
        camera.stop();
        zxingFilter.videoSink = null
        delete zxingFilter;
        delete videoOutput.videoSink
//        videoOutput = null
//        camera.deleteLater()
        delete camera
//        camera = null
        console.debug("Entire camera ibkect is destoing...");
    }
//    Component.onCompleted: {
//        delaySink.start();
//    }
    camera.onActiveChanged: {
        if (camera.active){
            console.debug("Camaea activated....")
            delaySink.start();
        }else{
            console.debug("Camera vas clossed correctly");
        }
    }

    Timer{
        id: delaySink
        interval: 4000
        repeat: false
        onTriggered: {
            console.info("Delat Sinc add....");
            zxingFilter.videoSink = videoOutput.videoSink
        }
    }
}
