#include "main/hello-greet.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#include <gtest/gtest.h>
#pragma clang diagnostic pop

TEST(HelloGreetTest, DefaultGreeting)
{
    auto greet{ get_greet( "world" ) };
    EXPECT_EQ(greet, "Hello world");
}

