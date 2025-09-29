load("//macros:mobile_binary.bzl", "mobile_binary" )
load("//macros:mobile_library.bzl", "mobile_library" )
load("//macros:mobile_test.bzl", "mobile_test" )
load("//macros:test_suite.bzl", "define_test_suites" )


mobile_library(
    name = "hello-greet",
    srcs = ["hello-greet.cc"],
    hdrs = ["hello-greet.h"],
    visibility = ["//visibility:public"],
    strip_include_prefix = "",
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

filegroup(
    name = "test-data",
    srcs = glob(["test-data/**"]),
    output_group = "",
)

mobile_test(
    name = "hello-world-test-file",
    srcs = ["tests/hello-test-file.cc"],
    args = ["--gtest_filter=HelloGreetTest.ReadFile"],
    data = [
        ":test-data",
    ],
)

mobile_test(
    name = "hello-test",
    srcs = [
        "hello-test.cc",
    ],
    deps = [
        "//main:hello-greet",
        "//lib:hello-time",
    ],
)

define_test_suites(
    name = "test-suites",
)
