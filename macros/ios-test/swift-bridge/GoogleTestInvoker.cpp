#include <gtest/gtest.h>

namespace GoogleTest
{

int executeGoogleTests(int argc, char ** argv)
{
    ::testing::InitGoogleTest( &argc, argv );
    return RUN_ALL_TESTS();

}

}
