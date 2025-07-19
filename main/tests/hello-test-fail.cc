#include "main/hello-greet.h"

#include <gtest/gtest.h>

TEST(HelloGreetTest, FailingTest)
{
    EXPECT_EQ(get_greet("bazel"), "Hello world"); // This will fail
}
