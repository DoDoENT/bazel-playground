#include "main/hello-greet.h"
#include "lib/hello-time.h"

#include <gtest/gtest.h>

TEST(HelloGreetTest, NonDefaultGreeting)
{
    EXPECT_EQ(get_greet("bazel"), "Hello bazel");
    print_localtime();
}
