load("//macros:macros.bzl", "mobile_binary" )


cc_library(
    name = "hello-greet",
    srcs = ["hello-greet.cc"],
    hdrs = ["hello-greet.h"],
    linkstatic = True,
    copts = select({
        "//conditions:default": [],
        "//:release": ["-O3", "-flto"],
    }),
)

mobile_binary(
    name = "hello-world",
    srcs = ["hello-world.cc"],
    deps = [
        ":hello-greet",
        "//lib:hello-time",
    ],
    copts = select({
        "//conditions:default": [],
        "//:release": ["-O3", "-flto"],
    }),
    linkopts = ["-Wl,-rpath,/usr/local/lib", "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu", "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"],
)

cc_test(
    name = "hello-world-test",
    srcs = ["hello-test.cc"],
    deps = [
        "@googletest//:gtest_main",
        "//main:hello-greet",
        "//lib:hello-time",
    ],
    linkopts = ["-Wl,-rpath,/usr/local/lib", "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu", "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"],
    args = ["--gtest_filter=*"],
)

