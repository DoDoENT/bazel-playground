#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>

#include <iostream>

int main()
{
    cv::Mat image(64, 64, CV_8UC3, cv::Scalar(240, 240, 240));
    cv::imshow("Qt integration test", image);
    cv::waitKey(100);
    cv::destroyAllWindows();
    std::cout << "Qt integration test passed\n";
    return 0;
}
