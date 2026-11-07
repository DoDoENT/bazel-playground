#include "ocv-test-helper.hh"

#include <opencv2/calib3d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>

#include <gtest/gtest.h>

#include <print>

TEST( DewarperTest, WarpPerspective )
{
    auto const origImage    { cv::imread( resolveImagePath( "image.png"    ), cv::IMREAD_COLOR ) };
    auto const expectedImage{ cv::imread( resolveImagePath( "dewarped.png" ), cv::IMREAD_COLOR ) };

    constexpr auto dewarpWidth  = 402;
    constexpr auto dewarpHeight = 326;

    auto const dewarpMat = []()
    {
        std::vector< cv::Point2f > input
        {
            cv::Point2f{  79, 388 },
            cv::Point2f{ 118,  31 },
            cv::Point2f{ 368, 413 },
            cv::Point2f{ 403,  60 }
        };

        std::vector< cv::Point2f > out
        {
            cv::Point2f{ 0          , 0            },
            cv::Point2f{ dewarpWidth, 0            },
            cv::Point2f{ 0          , dewarpHeight },
            cv::Point2f{ dewarpWidth, dewarpHeight }
        };

        return cv::getPerspectiveTransform( input, out );
    }();

    cv::Mat dewarpedImage;
    cv::warpPerspective( origImage, dewarpedImage, dewarpMat, cv::Size{ dewarpWidth, dewarpHeight }, cv::INTER_LINEAR, cv::BORDER_REFLECT101, 0 );

    cv::Mat diffImg;
    cv::absdiff( dewarpedImage, expectedImage, diffImg );

    auto const pixelSum{ cv::sum( diffImg ) };

    constexpr auto maxDiff = dewarpWidth * dewarpHeight * 255 * 0.02;

    std::println( "Blue Diff: %lf", pixelSum[ 0 ] );
    std::println( "Green Diff: %lf", pixelSum[ 1 ] );
    std::println( "Red Diff: %lf", pixelSum[ 2 ] );
    std::println( "Alpha Diff: %lf", pixelSum[ 3 ] );
    std::println( "Max diff: %lf", maxDiff );

    ASSERT_LE( pixelSum[ 0 ], maxDiff );
    ASSERT_LE( pixelSum[ 1 ], maxDiff );
    ASSERT_LE( pixelSum[ 2 ], maxDiff );
    ASSERT_LE( pixelSum[ 3 ], maxDiff );
}

