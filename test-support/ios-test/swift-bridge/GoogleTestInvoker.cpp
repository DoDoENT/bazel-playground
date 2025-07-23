#include "GoogleTestInvoker.hpp"
#include "test-support/ios-test/swift-bridge/GoogleTestSwift-Swift.h"

#include <gtest/gtest.h>

#include <iostream>
#include <memory>

namespace GoogleTest
{

std::string currentBundlePath()
{
    return std::string{ GoogleTestSwift::currentBundlePath() };
}

int executeGoogleTests( ArgVector const & args )
{
    std::cout << "Num params: " << args.size() << std::endl;
    for ( auto const & arg : args )
    {
        std::cout << arg << std::endl;
    }
    int argc = static_cast< int >( args.size() );
    auto argv{ std::make_unique< char *[] >( argc ) };
    for ( auto i{ 0 }; auto const & arg : args )
    {
        argv[ i++ ] = const_cast< char * >( arg.c_str() );
        std::cout << "ARGV: " << argv[ i - 1 ] << std::endl;
    }

    auto pArgv{ argv.get() };

   ::testing::InitGoogleTest( &argc, pArgv );
   return RUN_ALL_TESTS();
}

}
