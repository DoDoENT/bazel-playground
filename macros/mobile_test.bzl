load("//macros:ios_mobile_test.bzl", "ios_mobile_test")
load("//macros:android_mobile_test.bzl", "android_mobile_test")
load("@rules_cc//cc:cc_test.bzl", "cc_test")

def _mobile_test_impl(name, visibility, **kwargs):
    copts = kwargs.pop("copts") or select({
        "//conditions:default": [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        "//conditions:default": [],
    })
    deps = kwargs.pop("deps") or select({
        "//conditions:default": [],
    })
    srcs = kwargs.pop("srcs") or select({
        "//conditions:default": [],
    })
    tags = kwargs.pop("tags") or []
    args = kwargs.pop("args") or []
    data = kwargs.pop("data") or select({
        "//conditions:default": []
    })
    deps = deps + select({
        "//conditions:default": [
            "//test-support/paths:test-paths",
            "@googletest//:gtest_main",
        ]
    })
    cc_test(
        name = name,
        srcs = srcs,
        visibility = visibility,
        linkopts = linkopts + select({
            "@platforms//os:linux": [
                "-Wl,-rpath,/usr/local/lib",
                "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu",
                "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"
            ],
            "//conditions:default": [],
        }),
        deps = deps,
        tags = tags + ["host"],
        args = args,
        data = data,
        **kwargs,
    )
    ios_mobile_test(
        name = name + "-ios",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        tags = tags,
        args = args,
        data = data,
    )
    android_mobile_test(
        name = name + "-android",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        tags = tags,
        args = args,
        data = data,
    )


mobile_test = macro(
    implementation = _mobile_test_impl,
    inherit_attrs = native.cc_test,
    attrs = {
        "args": attr.string_list(
            default = [],
            doc = "Arguments for the iOS mobile test.",
            configurable = False,
        ),
    }
)

