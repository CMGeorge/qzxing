#include "QZXingFilterVideoSink.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include "qzxingimageprovider.h"

QZXingFilter::QZXingFilter(QObject *parent)
    : QObject(parent)
      , decoder(QZXing::DecoderFormat_QR_CODE)
      , decoding(false)
{
    qCritical() << "Test version 1";
    /// Connecting signals to handlers that will send signals to QML
    connect(&decoder, &QZXing::decodingStarted,
            this, &QZXingFilter::handleDecodingStarted);
    connect(&decoder, &QZXing::decodingFinished,
            this, &QZXingFilter::handleDecodingFinished);
}

QZXingFilter::~QZXingFilter()
{
    if(!processThread.isFinished()) {
        processThread.cancel();
        processThread.waitForFinished();
    }
}

void QZXingFilter::handleDecodingStarted()
{
    decoding = true;
    emit decodingStarted();
    emit isDecodingChanged();
}

void QZXingFilter::handleDecodingFinished(bool succeeded)
{
    decoding = false;
    emit decodingFinished(succeeded, decoder.getProcessTimeOfLastDecoding());
    emit isDecodingChanged();
}

void QZXingFilter::setOrientation(int orientation)
{
    if (orientation_ == orientation) {
        return;
    }

    orientation_ = orientation;
    emit orientationChanged(orientation_);
}

int QZXingFilter::orientation() const
{
    return orientation_;
}

void QZXingFilter::setVideoSink(QObject *videoSink){
    m_videoSink = qobject_cast<QVideoSink*>(videoSink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged, this, &QZXingFilter::processFrame,Qt::DirectConnection);
}

void QZXingFilter::processFrame(const QVideoFrame &frame) {
    //#ifdef Q_OS_ANDROID
    //    m_videoSink->setRhi(nullptr); // https://bugreports.qt.io/browse/QTBUG-97789
    //    QVideoFrame f(frame);
    //    f.map(QVideoFrame::ReadOnly);
    //#else
    //    const QVideoFrame &f = frame;
    //#endif // Q_OS_ANDROID
    //    return;
    if(!isDecoding() && processThread.isFinished()){

        decoding = true;
        bool didWeMapTheFrame = false;
        if (!static_cast<QVideoFrame>(frame).isMapped()) {
#ifdef Q_OS_ANDROID
            m_videoSink->setRhi(
                nullptr); // https://bugreports.qt.io/browse/QTBUG-97789
#endif
            didWeMapTheFrame =
                static_cast<QVideoFrame>(frame).map(QVideoFrame::ReadOnly);
        }

        if (static_cast<QVideoFrame>(frame).isMapped()) {
            QImage image = frame.toImage();
            if (!image.isNull()) {
                processThread = QtConcurrent::run([=]() {
                    //                    if (image.isNull()) {
                    //                        qDebug() << "QZXingFilter error:
                    //                        Cant create image "
                    //                                    "file to process.";
                    //                        decoding = false;
                    //                        return;
                    //                    }

                    QImage frameToProcess(image);
                    const QRect &rect = captureRect.toRect();

                    if (captureRect.isValid() &&
                        frameToProcess.size() != rect.size()) {
                        frameToProcess = image.copy(rect);
                    }

                    if (!orientation_) {
                        decoder.decodeImage(frameToProcess);
                    } else {
                        QTransform transformation;
                        transformation.translate(
                            frameToProcess.rect().center().x(),
                            frameToProcess.rect().center().y());
                        transformation.rotate(-orientation_);

                        QImage translatedImage =
                            frameToProcess.transformed(transformation);

                        decoder.decodeImage(translatedImage);
                    }

                    //        static int i=0;
                    //        qDebug() << "image.size()" <<
                    //        frameToProcess.size(); qDebug() <<
                    //        "image.format()" << frameToProcess.format(); const
                    //        QString path =
                    //        QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)
                    //        + "/qrtest/test_" + QString::number(i++ % 100) +
                    //        ".png"; qDebug() << "saving image" << i << "at:"
                    //        << path << frameToProcess.save(path);

                    decoder.decodeImage(frameToProcess, frameToProcess.width(),
                                        frameToProcess.height());
                    decoding = false;
                });
            } else {
                decoding = false;
            }
            if(didWeMapTheFrame) static_cast<QVideoFrame>(frame).unmap();
        }else {
            decoding = false;
        }
    }

         //#ifdef Q_OS_ANDROID
         //    frame.unmap();
         //#endif
}
