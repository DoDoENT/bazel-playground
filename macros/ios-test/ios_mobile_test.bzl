load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_swift//mixed_language:mixed_language_library.bzl", "mixed_language_library")
load(
    "@rules_apple//apple/testing/default_runner:ios_test_runner.bzl",
    "ios_test_runner",
)

load("@rules_xcodeproj//xcodeproj:top_level_target.bzl", "top_level_target")
load("@rules_xcodeproj//xcodeproj:xcodeproj.bzl", "xcodeproj")
load("@rules_xcodeproj//xcodeproj:xcschemes.bzl", "xcschemes")

def _ios_mobile_test_impl(name, visibility, srcs, copts, deps, args, tags):
    mixed_language_library(
        name = name + "-ios-srcs",
        swift_srcs = [
            "//macros/ios-test/swift-bridge:GoogleTestsSwiftIosLoader",
        ],
        clang_srcs = srcs + [
            "//macros/ios-test/swift-bridge:GoogleTestInvokerSource",
        ],
        hdrs = [
            "//macros/ios-test/swift-bridge:GoogleTestInvokerHeader",
        ],
        clang_copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        swift_copts = [
            "-cxx-interoperability-mode=default",
        ],
        visibility = ["//visibility:public"],
        deps = deps + [
            "@googletest//:gtest_main",
        ],
        testonly = True,
        tags = ["manual"],
        alwayslink = True,
    )
    ios_unit_test(
        name = name,
        visibility = visibility + ["//visibility:public"],
        deps = [
            name + "-ios-srcs",
        ],
        minimum_os_version = "15.0",
        provisioning_profile = "//macros/ios-test:xcode_profile",
        test_host = "//macros/ios-test/GoogleTestHost:GoogleTestHost",
        runner = "@rules_apple//apple/testing/default_runner:ios_xctestrun_ordered_runner",
        tags = tags + ["ios"],
        target_compatible_with = [
            "@platforms//os:macos",
        ],
    )
    xcodeproj(
        name = name + "-xcodeproj",
        project_name = name,
        tags = ["manual"],
        top_level_targets = [
            top_level_target(name, target_environments = ["device", "simulator"]),
            "//macros/ios-test/GoogleTestHost:GoogleTestHost"
        ],
        xcschemes = [
            xcschemes.scheme(
                name = name,
                test = xcschemes.test(
                    args = args,
                    test_targets = [name],
                )
            )
        ]
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
        "args": attr.string_list(
            default = [],
            doc = "Arguments for the iOS mobile test.",
            configurable = False,
        ),
        "tags": attr.string_list(
            default = [],
            doc = "Arguments for the iOS mobile test.",
            configurable = False,
        ),
    },
)
