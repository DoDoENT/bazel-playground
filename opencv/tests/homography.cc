#include "ocv-test-helper.hh"

#include <opencv2/calib3d.hpp>
#include <opencv2/imgcodecs.hpp>

#include <gtest/gtest.h>

TEST( FindHomograpyTest, find )
{
    [[ maybe_unused ]] std::array const pts
    {
        cv::Point{ 0, 0 },
        cv::Point{ 1, 0 },
        cv::Point{ 0, 1 },
        cv::Point{ 1, 1 }
    };

    cv::Mat const homography{ cv::findHomography( pts, pts, cv::RANSAC )};
    ASSERT_FALSE( homography.empty() );
}
