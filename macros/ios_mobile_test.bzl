load("@rules_apple//apple:ios.bzl", "ios_unit_test")
load("@rules_apple//apple:resources.bzl", "apple_resource_group")

load("@rules_xcodeproj//xcodeproj:top_level_target.bzl", "top_level_target")
load("@rules_xcodeproj//xcodeproj:xcodeproj.bzl", "xcodeproj")
load("@rules_xcodeproj//xcodeproj:xcschemes.bzl", "xcschemes")

load("//macros:mobile_library.bzl", "mobile_library")
load(":constants.bzl", "TAG_IOS")

def _ios_mobile_test_impl(name, visibility, srcs, copts, conlyopts, cxxopts, linkopts, deps, args, tags, data, defines, local_defines):
    mobile_library(
        name = name + "-ios-srcs",
        srcs = srcs,
        deps = deps + [
            Label("//test-support/ios-test/swift-bridge:googletest-ios-swift-bridge"),
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
            native.package_relative_label(":" + name + "-ios-srcs"),
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
        ],
    )
    xcodeproj(
        name = name + "-xcodeproj",
        project_name = name,
        tags = ["manual"],
        top_level_targets = [
            top_level_target(name, target_environments = ["device", "simulator"]),
            top_level_target(Label("//test-support/ios-test/GoogleTestHost:GoogleTestHost"), target_environments = ["device", "simulator"]),
        ],
        xcschemes = [
            xcschemes.scheme(
                name = name,
                test = xcschemes.test(
                    args = args,
                    test_targets = [
                        xcschemes.test_target(native.package_relative_label(":" + name))
                    ],
                    build_targets = [
                        xcschemes.top_level_build_target(Label("//test-support/ios-test/GoogleTestHost:GoogleTestHost")),
                    ]
                ),
                run = xcschemes.run(
                    launch_target = xcschemes.launch_target(Label("//test-support/ios-test/GoogleTestHost:GoogleTestHost")),
                )
            )
        ],
        target_compatible_with = [
            # note: this target needs to run on macOS as Xcode project is generated there
            Label("@platforms//os:macos"),
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
    },
)
