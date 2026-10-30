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
    visibility = ["//visibility:public"],
)

filegroup(
    name = "test-data",
    srcs = glob(["test-data/**"]),
)

mobile_test(
    name = "hello-world-test",
    srcs = [
        "tests/hello-test-file.cc",
        "tests/hello-test-non-default.cc",
        "tests/hello-test-default.cc",
        "hello-test.cc",
    ],
    shard_count = 3,
    data = [
        ":test-data",
    ],
    deps = [
        "//main:hello-greet",
        "//lib:hello-time",
    ],
)

define_test_suites(
    name = "test-suites",
)
