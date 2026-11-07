#include "ocv-test-helper.hh"

#include <opencv2/features2d.hpp>
#include <opencv2/imgcodecs.hpp>

#include <gtest/gtest.h>

#include <vector>

TEST( SiftTest, detect )
{
    auto const input{ cv::imread( resolveImagePath( "image.png" ), cv::IMREAD_COLOR ) };
    ASSERT_FALSE( input.empty() );

    auto const detector{ cv::SIFT::create() };
    ASSERT_TRUE( detector );

    std::vector< cv::KeyPoint > keypoints;
    detector->detect( input, keypoints);
    ASSERT_FALSE( keypoints.empty() );
}

TEST( SiftTest, match )
{
    auto const input{ cv::imread( resolveImagePath( "image.png" ), cv::IMREAD_COLOR ) };
    ASSERT_FALSE( input.empty() );

    auto const detector{ cv::SIFT::create() };
    ASSERT_TRUE( detector );

    auto const matcher
    {
        cv::makePtr< cv::FlannBasedMatcher >
        (
            cv::makePtr< cv::flann::KDTreeIndexParams >( 5  /* trees  */ ),
            cv::makePtr< cv::flann::SearchParams      >( 50 /* checks */ )
        )
    };
    ASSERT_TRUE( matcher );

    std::vector< cv::KeyPoint > keypoints;
    cv::Mat descriptors;
    detector->detectAndCompute( input, cv::noArray(), keypoints, descriptors );
    ASSERT_FALSE( keypoints  .empty() );
    ASSERT_FALSE( descriptors.empty() );

    std::vector< std::vector< cv::DMatch> > matches;
    matcher->knnMatch( descriptors, descriptors, matches, 2 );
    ASSERT_FALSE( matches.empty() );
}
