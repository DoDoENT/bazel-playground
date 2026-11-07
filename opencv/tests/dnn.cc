#include "ocv-test-helper.hh"

#include <opencv2/imgcodecs.hpp>
#include <opencv2/dnn.hpp>

#include <gtest/gtest.h>

#include <print>

TEST( DNNTest, testSuperResolution )
{
    cv::dnn::Net srnet
    {
        cv::dnn::readNet
        (
            resolveImagePath( "sr.onnx" )
        )
    };


    auto const src{ cv::imread( resolveImagePath( "expected-result.png" ), cv::IMREAD_GRAYSCALE ) };

    cv::Mat blob;
    cv::dnn::blobFromImage( src, blob, 1.0 / 255, cv::Size( src.cols, src.rows ), { 0.0f }, false, false );

    srnet.setInput( blob );
    auto prob = srnet.forward();

    cv::Mat dst( prob.size[ 2 ], prob.size[ 3 ], CV_8UC1 );

    for ( int row = 0; row < prob.size[ 2 ]; row++ ) {
        const float * prob_score = prob.ptr< float >( 0, 0, row );
        for ( int col = 0; col < prob.size[ 3 ]; col++ ) {
            float pixel = prob_score[ col ] * 255.0f;
            dst.at< uint8_t >( row, col ) = static_cast< uint8_t >( std::clamp< float >( pixel, 0.0f, 255.0f ) );
        }
    }

    auto const expected{ cv::imread( resolveImagePath( "superres.png" ), cv::IMREAD_GRAYSCALE ) };

    cv::Mat diffImg;
    cv::absdiff( dst, expected, diffImg );

    auto const pixelSum{ cv::sum( diffImg ) };

    auto const maxDiff{ expected.cols * expected.rows * 255 * 0.02 };

    std::println( "Diff: %lf", pixelSum[ 0 ] );
    std::println( "Max allowed diff: %lf", maxDiff );

    ASSERT_LE( pixelSum[ 0 ], maxDiff );
}

