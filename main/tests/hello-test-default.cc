#include "main/hello-greet.h"

#include <gtest/gtest.h>

TEST(HelloGreetTest, DefaultGreeting)
{
    auto greet{ get_greet( "world" ) };
    EXPECT_EQ(greet, "Hello world");
}

