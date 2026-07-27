#include <Paths.h>

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>

#include <gtest/gtest.h>

#ifdef __ANDROID__
#include "PathProvider.hpp"
#endif

namespace 
{
    std::string resolveImagePath( std::string_view filename )
    {
#ifdef __ANDROID__
        return AndroidPaths::internalStoragePath() + '/' + resolveTestDataPath( filename );
#else 
        return resolveTestDataPath( filename );
#endif
    }
}

TEST(OpenCVTest, resizeAndGrayscale)
{
    auto path{ resolveImagePath( "image.png" ) };
    std::cout << "Loading file: " << path << std::endl;
    cv::Mat inputImage{ cv::imread( path, cv::IMREAD_COLOR ) };

    ASSERT_FALSE( inputImage.empty() ) << "Failed to load file: " << path;

    std::cout << "Input image size: " << inputImage.cols << "x" << inputImage.rows << std::endl;

    cv::Mat grayImage;
    cv::cvtColor( inputImage, grayImage, cv::COLOR_BGR2GRAY );

    cv::Mat resizedImage;
    cv::resize( grayImage, resizedImage, cv::Size{ 103, 120 } );

    auto const expectedPath{ resolveImagePath( "expected-result.png" ) };

    cv::Mat expectedImage{ cv::imread( expectedPath, cv::IMREAD_GRAYSCALE ) };

    cv::Mat diffImg;
    cv::absdiff( resizedImage, expectedImage, diffImg );

    auto const pixelSum{ cv::sum( diffImg ) };

    EXPECT_EQ( 0, pixelSum.val[ 0 ] );
}
