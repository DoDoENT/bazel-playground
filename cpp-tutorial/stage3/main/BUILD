load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")


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

cc_binary(
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

string_flag(
    name = "wasm_flavor",
    build_setting_default = "basic",
)

config_setting(
    name = "wasm_basic",
    flag_values = {":wasm_flavor": "basic"},
)

config_setting(
    name = "wasm_advanced",
    flag_values = {":wasm_flavor": "advanced"},
)

config_setting(
    name = "wasm_advanced_threads",
    flag_values = {":wasm_flavor": "advanced-threads"},
)

# build with bazel build //main:hello-world-wasm --//main:wasm_flavor=advanced

wasm_cc_binary(
    name = "hello-world-wasm",
    cc_target = ":hello-world",
    outputs = [
        "hello-world.wasm",
        "hello-world.js",
    ],
    simd = select({
        ":wasm_advanced": True,
        ":wasm_advanced_threads": True,
        "//conditions:default": False,
    }),
    threads = select({
        ":wasm_advanced_threads": "emscripten",
        "//conditions:default": "off",
    }),
)

cc_test(
    name = "hello-world-test",
    srcs = ["hello-test.cc"],
    deps = [
        "@googletest//:gtest_main",
        "//main:hello-greet",
    ],
    linkopts = ["-Wl,-rpath,/usr/local/lib", "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu", "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"],
    args = ["--gtest_filter=*"],
)

