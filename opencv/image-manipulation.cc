#include <Paths.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#include <gtest/gtest.h>
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wdocumentation"
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#pragma clang diagnostic pop

TEST(OpenCVTest, resizeAndGrayscale)
{
    auto path{ "opencv/image.png" };
    std::cout << "Loading file: " << path << std::endl;
    cv::Mat inputImage{ cv::imread( path, cv::IMREAD_COLOR ) };

    std::cout << "Input image size: " << inputImage.cols << "x" << inputImage.rows << std::endl;

    cv::Mat grayImage;
    cv::cvtColor( inputImage, grayImage, cv::COLOR_BGR2GRAY );

    cv::Mat resizedImage;
    cv::resize( grayImage, resizedImage, cv::Size{ 103, 120 } );

    auto const expectedPath{ "opencv/expected-result.png" };

    cv::Mat expectedImage{ cv::imread( expectedPath, cv::IMREAD_GRAYSCALE ) };

    cv::Mat diffImg;
    cv::absdiff( resizedImage, expectedImage, diffImg );

    auto const pixelSum{ cv::sum( diffImg ) };

    EXPECT_EQ( 0, pixelSum.val[ 0 ] );
}
