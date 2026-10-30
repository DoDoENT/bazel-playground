#include "hello-greet.h"
#include "lib/hello-time.h"

#include <gtest/gtest.h>

TEST(HelloGreetTest, DefaultGreeting2)
{
    auto greet{ get_greet( "world" ) };
    EXPECT_EQ(greet, "Hello world");
}

TEST(HelloGreetTest, NonDefaultGreeting2)
{
    EXPECT_EQ(get_greet("bazel"), "Hello bazel");
    print_localtime();
}

TEST(HelloGreetTest, DISABLED_FailingTest)
{
    EXPECT_EQ(get_greet("bazel"), "Hello world"); // This will fail
}
