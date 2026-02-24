#include "main/hello-greet.h"

#pragma clang diagnostic push
#ifndef __APPLE__
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#endif
#include <gtest/gtest.h>
#pragma clang diagnostic pop

TEST(HelloGreetTest, DefaultGreeting)
{
    auto greet{ get_greet( "world" ) };
    EXPECT_EQ(greet, "Hello world");
}

