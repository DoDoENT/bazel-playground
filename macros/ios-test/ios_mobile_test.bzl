load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_apple//apple:apple.bzl", "apple_static_xcframework")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

def _ios_mobile_test_impl(name, visibility, srcs, copts, deps):
    objc_library(
        name = name + "-ios-srcs",
        srcs = srcs + [
            "//macros/ios-test:GoogleTestsIosHelper",
        ],
        visibility = ["//visibility:private"],
        copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        deps = deps + [
            "@googletest//:gtest_main",
        ],
        testonly = True,
        tags = ["manual"],
    )
    ios_unit_test(
        name = name,
        visibility = visibility,
        deps = [
            name + "-ios-srcs",
        ],
        minimum_os_version = "15.0",
        test_host = "//macros/ios-test/GoogleTestHost:GoogleTestHost",
        runner = "@rules_apple//apple/testing/default_runner:ios_xctestrun_ordered_runner",
    )


ios_mobile_test = macro(
    implementation = _ios_mobile_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Source files for the iOS mobile test.",
        ),
        "copts": attr.string_list(
            default = [],
            doc = "Compiler options for the iOS mobile test.",
        ),
        "deps": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Dependencies for the iOS mobile test.",
        ),
    },
)
