load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_apple//apple:resources.bzl", "apple_resource_group")

load("@rules_xcodeproj//xcodeproj:top_level_target.bzl", "top_level_target")
load("@rules_xcodeproj//xcodeproj:xcodeproj.bzl", "xcodeproj")
load("@rules_xcodeproj//xcodeproj:xcschemes.bzl", "xcschemes")

load("//macros:mobile_library.bzl", "mobile_library")
load(":constants.bzl", "TAG_IOS")

def _ios_mobile_test_impl(name, visibility, srcs, copts, deps, args, tags, data):
    mobile_library(
        name = name + "-ios-srcs",
        srcs = srcs,
        deps = deps + [
            "//test-support/ios-test/swift-bridge:googletest-ios-swift-bridge",
        ],
        copts = copts,
        testonly = True, 
        alwayslink = True,
    )

    apple_resource_group(
        name = name + "-resources",
        structured_resources = data,
    )

    # note: to run on device, use --test_arg=--destination=platform=ios_device,id=device-id --ios_multi_cpus=arm64
    ios_unit_test(
        name = name,
        bundle_id = "com.example." + name + "Tests",
        visibility = visibility + ["//visibility:public"],
        deps = [
            name + "-ios-srcs",
        ],
        env = {
            "TEST_ARGS": " ".join(args),
            "TEST_ARGC": str(len(args)),
        },
        minimum_os_version = "15.0",
        provisioning_profile = "//test-support/ios-test:xcode_profile",
        test_host = "//test-support/ios-test/GoogleTestHost:GoogleTestHost",
        tags = tags + [TAG_IOS, "exclusive"], # need to be exclusive to prevent parallel invocation on the same device
        resources = [name + "-resources"],
        runner = "//test-support/ios-test:test_runner",
        target_compatible_with = [
            # note: this target needs to run on macOS and introduces transition to iOS
            "@platforms//os:macos",
        ],
    )
    xcodeproj(
        name = name + "-xcodeproj",
        project_name = name,
        tags = ["manual"],
        top_level_targets = [
            top_level_target(name, target_environments = ["device", "simulator"]),
            "//test-support/ios-test/GoogleTestHost:GoogleTestHost"
        ],
        xcschemes = [
            xcschemes.scheme(
                name = name,
                test = xcschemes.test(
                    args = args,
                    test_targets = [name],
                    build_targets = [
                        "//test-support/ios-test/GoogleTestHost:GoogleTestHost"
                    ]
                ),
                run = xcschemes.run(
                    launch_target = "//test-support/ios-test/GoogleTestHost:GoogleTestHost",
                )
            )
        ],
        target_compatible_with = [
            # note: this target needs to run on macOS as Xcode project is generated there
            "@platforms//os:macos",
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
    },
)
