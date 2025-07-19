load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")
load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)
load("@rules_swift//mixed_language:mixed_language_library.bzl", "mixed_language_library")

def _ios_mobile_test_impl(name, visibility, srcs, copts, deps, args):
    # objc_library(
    #     name = name + "-ios-srcs",
    #     srcs = srcs + [
    #         "//macros/ios-test:GoogleTestsIosHelper",
    #     ],
    #     visibility = ["//visibility:public"],
    #     copts = copts + select({
    #         "//conditions:default": [],
    #         "//:release": ["-O3", "-flto"],
    #     }),
    #     deps = deps + [
    #         "@googletest//:gtest_main",
    #     ],
    #     testonly = True,
    #     tags = ["manual"],
    # )
    mixed_language_library(
        name = name + "-ios-srcs",
        swift_srcs = [
            "//macros/ios-test/swift-bridge:GoogleTestsSwiftIosLoader",
        ],
        clang_srcs = srcs,
        textual_hdrs = [
            "//macros/ios-test/swift-bridge:GoogleTestSwiftIosBridgeHeader",
        ],
        clang_copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        # module_map = "//macros/ios-test/swift-bridge:GoogleTestSwiftModuleMap",
        module_name = "GoogleTestsIos",
        visibility = ["//visibility:public"],
        deps = deps + [
            "@googletest//:gtest_main",
        ],
        testonly = True,
        tags = ["manual"],
    )
    ios_unit_test(
        name = name,
        visibility = visibility + ["//visibility:public"],
        deps = [
            name + "-ios-srcs",
        ],
        args = args,
        minimum_os_version = "15.0",
        test_host = "//macros/ios-test/GoogleTestHost:GoogleTestHost",
        runner = "@rules_apple//apple/testing/default_runner:ios_xctestrun_ordered_runner",
    )
    xcodeproj(
        name = name + "-xcodeproj",
        project_name = name,
        tags = ["manual"],
        top_level_targets = [
            top_level_target(name, target_environments = ["device", "simulator"]),
            "//macros/ios-test/GoogleTestHost:GoogleTestHost"
        ],
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
        ),
    },
)
