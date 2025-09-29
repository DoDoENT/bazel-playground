#include "GoogleTestInvoker.hpp"
#include "test-support/ios-test/swift-bridge/GoogleTestSwift-Swift.h"

#include <gtest/gtest.h>

#include <memory>

namespace GoogleTest
{

std::string currentBundlePath()
{
    return std::string{ GoogleTestSwift::currentBundlePath() };
}

std::string currentOutputDirPath()
{
    return std::string{ GoogleTestSwift::currentOutputDirPath() };
}

int executeGoogleTests( ArgVector const & args )
{
    int argc = static_cast< int >( args.size() );
    auto argv{ std::make_unique< char *[] >( static_cast< std::size_t >( argc ) ) };
    for ( auto i{ 0U }; auto const & arg : args )
    {
        argv[ i++ ] = const_cast< char * >( arg.c_str() );
    }

    auto pArgv{ argv.get() };

   ::testing::InitGoogleTest( &argc, pArgv );
   return RUN_ALL_TESTS();
}

}
