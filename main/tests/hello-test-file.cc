#include <TestPaths/TestPaths.hpp>

#include <gtest/gtest.h>

#include <iostream>
#include <fstream>

TEST(HelloGreetTest, ReadFile)
{
    auto path{ resolveTestDataPath( "subfolder/hello.txt" ) };
    std::cout << "Loading file: " << path << std::endl;
    std::ifstream file{ path };
    std::string contents;
    std::getline( file, contents );
    EXPECT_STREQ( contents.c_str(), "Hello, Bazel!" );
}
