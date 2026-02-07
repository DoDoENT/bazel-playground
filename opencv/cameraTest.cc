#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wdocumentation"
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#pragma clang diagnostic pop

int main()
{
    cv::namedWindow( "Camera", cv::WINDOW_AUTOSIZE );
    cv::VideoCapture cap( 0 );
    if ( !cap.isOpened() )
    {
        return -1;
    }

    cv::Mat frame;
    for ( ;; )
    {
        cap >> frame;
        if ( frame.empty() )
        {
            break;
        }
        // draw a text overlay to show that highgui is functional
        cv::putText( frame, "Hello, OpenCV!", cv::Point( 50, 50 ), cv::FONT_HERSHEY_SIMPLEX, 1.0, CV_RGB( 255, 0, 0 ), 2 );
        cv::imshow( "Camera", frame );
        if ( cv::waitKey( 30 ) == 27 )
        {
            break;
        }
    }
    return 0;
}
