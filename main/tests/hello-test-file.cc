#include <Paths.h>

#pragma clang diagnostic push
#ifndef __APPLE__
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#endif
#include <gtest/gtest.h>
#pragma clang diagnostic pop

TEST(HelloGreetTest, ReadFile)
{
    auto path{ resolveTestDataPath( "subfolder/hello.txt" ) };
    std::cout << "Loading file: " << path << std::endl;
    auto buffer{ readFileToBuffer( path ) };
    EXPECT_STREQ( reinterpret_cast< char const * >( buffer.data.get() ), "Hello, Bazel!\n" );
}
