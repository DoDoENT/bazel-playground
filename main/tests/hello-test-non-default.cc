#include "main/hello-greet.h"
#include "lib/hello-time.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcharacter-conversion"
#include <gtest/gtest.h>
#pragma clang diagnostic pop

TEST(HelloGreetTest, NonDefaultGreeting)
{
    EXPECT_EQ(get_greet("bazel"), "Hello bazel");
    print_localtime();
}
