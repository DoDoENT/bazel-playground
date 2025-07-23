load("//macros:mobile_binary.bzl", "mobile_binary" )
load("//macros:mobile_library.bzl", "mobile_library" )
load("//macros:mobile_test.bzl", "mobile_test" )


mobile_library(
    name = "hello-greet",
    srcs = ["hello-greet.cc"],
    hdrs = ["hello-greet.h"],
    linkstatic = True,
    visibility = ["//visibility:public"],
)

mobile_binary(
    name = "hello-world",
    srcs = ["hello-world.cc"],
    deps = [
        ":hello-greet",
        "//lib:hello-time",
    ],
)

mobile_test(
    name = "hello-world-test-default",
    srcs = ["tests/hello-test-default.cc"],
    deps = [
        "//main:hello-greet",
    ],
    args = ["--gtest_filter=HelloGreetTest.DefaultGreeting"],
)

mobile_test(
    name = "hello-world-test-non-default",
    srcs = ["tests/hello-test-non-default.cc"],
    deps = [
        "//main:hello-greet",
        "//lib:hello-time",
    ],
    args = ["--gtest_filter=HelloGreetTest.NonDefaultGreeting"],
)

mobile_test(
    name = "hello-world-test-file",
    srcs = ["tests/hello-test-file.cc"],
    deps = [
        "//paths:paths",
    ],
    args = ["--gtest_filter=HelloGreetTest.ReadFile"],
)

