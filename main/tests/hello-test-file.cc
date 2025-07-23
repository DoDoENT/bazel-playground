#include <Paths/Paths.hpp>

#include <gtest/gtest.h>

#include <fstream>

TEST(HelloGreetTest, ReadFile)
{
    auto path{ resolveTestDataPath( "subfolder/hello.txt" ) };
    std::ifstream file{ path };
    std::string contents;
    std::getline( file, contents );
    EXPECT_STREQ( contents.c_str(), "Hello, Bazel!" );
}
