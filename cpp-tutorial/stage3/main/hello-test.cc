#include "hello-greet.h"

#include <gtest/gtest.h>

TEST(HelloGreetTest, DefaultGreeting) {
  EXPECT_EQ(get_greet("world"), "Hello world");
}
