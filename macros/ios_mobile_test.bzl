load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_apple//apple:resources.bzl", "apple_resource_group")

load("//macros:mobile_library.bzl", "mobile_library")
load(":constants.bzl", "TAG_IOS")
load(":test_utils.bzl", "prepare_assets")

def _ios_mobile_test_impl(name, visibility, srcs, copts, conlyopts, cxxopts, linkopts, deps, args, tags, data, defines, local_defines, size, timeout, target_compatible_with):
    mobile_library(
        name = name + "-srcs",
        srcs = srcs,
        deps = deps + [
            Label("//test-support/ios-test/swift-bridge:googletest-ios-swift-bridge"),
            Label("@googletest//:gtest_main"),
        ],
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
        testonly = True,
        alwayslink = True,
        local_defines = local_defines,
        defines = defines,
    )

    prepare_assets(
        name = name + "-assets",
        data = data,
        deps_runfiles = deps + srcs,
        testonly = True,
    )

    apple_resource_group(
        name = name + "-resources",
        structured_resources = [
            native.package_relative_label(":" + name + "-assets"),
        ],
        strip_structured_resources_prefixes = [
            name + "-assets",
        ],
        testonly = True,
    )

    # note: to run on device, use --test_arg=--destination=platform=ios_device,id=device-id --ios_multi_cpus=arm64
    ios_unit_test(
        name = name,
        bundle_id = "com.example." + name + "Tests",
        visibility = visibility + ["//visibility:public"],
        deps = [
            native.package_relative_label(":" + name + "-srcs"),
        ],
        env = {
            "TEST_ARGS": " ".join(args),
            "TEST_ARGC": str(len(args)),
        },
        minimum_os_version = "15.0",
        provisioning_profile = Label("//test-support/ios-test:xcode_profile"),
        test_host = Label("//test-support/ios-test/GoogleTestHost:GoogleTestHost"),
        tags = tags + [TAG_IOS, "exclusive"], # need to be exclusive to prevent parallel invocation on the same device
        resources = [
            native.package_relative_label(":" + name + "-resources")
        ],
        runner = Label("//test-support/ios-test:test_runner"),
        target_compatible_with = [
            # note: this target needs to run on macOS and introduces transition to iOS
            Label("@platforms//os:macos"),
        ] + target_compatible_with,
        size = size,
        timeout = timeout,
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
        "conlyopts": attr.string_list(
            default = [],
            doc = "C compiler options for the iOS mobile test.",
        ),
        "cxxopts": attr.string_list(
            default = [],
            doc = "C++ compiler options for the iOS mobile test.",
        ),
        "linkopts": attr.string_list(
            default = [],
            doc = "Linker options for the iOS mobile test.",
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
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Test data files",
        ),
        "defines": attr.string_list(
            default = [],
            doc = "Preprocessor defines for the Android mobile test.",
        ),
        "local_defines": attr.string_list(
            default = [],
            doc = "Preprocessor defines for the Android mobile test that should not be propagated to dependents.",
        ),
        "size": attr.string(
            default = "medium",
            doc = "Size of the test: small, medium, large, or enormous.",
            configurable = False
        ),
        "timeout": attr.string(
            default = "moderate",
            doc = "Timeout for the test: short, moderate, long, or eternal.",
            configurable = False
        ),
        "target_compatible_with": attr.label_list(
            default = [],
            doc = "Compatibility constraints for the iOS mobile test.",
        ),
    },
)
