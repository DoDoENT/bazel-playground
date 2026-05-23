#include "hello-greet.h"
#include "lib/hello-time.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#include <gtest/gtest.h>
#pragma clang diagnostic pop

TEST(HelloGreetTest, DefaultGreeting)
{
    auto greet{ get_greet( "world" ) };
    EXPECT_EQ(greet, "Hello world");
}

TEST(HelloGreetTest, NonDefaultGreeting)
{
    EXPECT_EQ(get_greet("bazel"), "Hello bazel");
    print_localtime();
}

TEST(HelloGreetTest, DISABLED_FailingTest)
{
    EXPECT_EQ(get_greet("bazel"), "Hello world"); // This will fail
}
