#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wdocumentation"
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#pragma clang diagnostic pop

#include <iostream>

int main(int argc, char ** argv )
{
    // Check for valid command line arguments, print usage
    if ( argc != 2 )
    {
        std::cout << "Usage: displayImage <Image_Path>\n";
        return -1;
    }

    std::cout << "Using OpenCV version " << CV_VERSION << "\n";

    // Read the image file
    cv::Mat image;
    image = cv::imread( argv[1], cv::IMREAD_COLOR );

    // Check for failure
    if ( image.empty() )
    {
        std::cout << "Could not open or find the image\n";
        return -1;
    }

    // Create a window
    cv::namedWindow( "Display window", cv::WINDOW_AUTOSIZE );

    // Show our image inside the created window
    cv::imshow( "Display window", image );

    // Wait for a keystroke in the window
    cv::waitKey(0);
    return 0;
}
