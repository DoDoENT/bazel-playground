load("@rules_android//android:rules.bzl", "android_binary")
load("//test-support/android-test/android_instrumentation_test:android_instrumentation_test.bzl", "android_instrumentation_test")
load("//macros:mobile_library.bzl", "mobile_library")
load(":test_utils.bzl", "prepare_assets")
load(":constants.bzl", "TAG_ANDROID")
load(":android_build_config.bzl", "android_build_config")
load(":android_utils.bzl", "SANITIZER_SUPPORT_LIBS")

def _android_mobile_test_impl(name, visibility, srcs, copts, conlyopts, cxxopts, linkopts, deps, args, tags, data, defines, local_defines, deploy_resources, size, timeout, target_compatible_with):
    # Always use the same package name, as this makes it easier to monitor test runs with ADB and it's not
    # possible to run multiple tests simultaneously anyway (they would conflict on the device).
    package_name = "com.example.testrunner"

    mobile_library(
        name = name + "-srcs",
        srcs = srcs + [
            Label("//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherCppSources"),
        ],
        deps = deps + [
            Label("//macros/android-helpers/exerunner/PathProvider"),
            Label("@googletest//:gtest_main"),
        ],
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts + [
            "-landroid",
            "-llog",
        ],
        testonly = True,
        alwayslink = True,
        linkstatic = False,
        local_defines = local_defines,
        defines = defines,
        tags = ["manual"],
    )

    android_build_config(
        name = name + "-build-config",
        package = package_name,
        application_id = package_name,
        build_config_fields = {
            "TEST_ARGS": ["String[]", 'new String[]{' + ",".join(['"' + x + '"' for x in args]) + '}'],
            "NATIVE_LIB_NAME": ["String", '"' + name + '-test-app"'],
            "DEPLOY_RESOURCES": ["boolean", "true" if deploy_resources else "false"],
            "PKG_ROOT": ["String", '"' + native.package_name().split("/")[0] + '"'],
        },
    )

    prepare_assets(
        name = name + "-assets",
        data = data,
        deps_runfiles = deps + srcs,
        testonly = True,
    )

    android_binary(
        name = name + "-test-app",
        srcs = [
            native.package_relative_label(":" + name + "-build-config"),
            Label("//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherJavaSources"),
        ],
        custom_package = package_name,
        manifest = Label("//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherManifest"),
        manifest_values = {
            "applicationId": package_name,
            "minSdkVersion": "21",
            "targetSdkVersion": "31",
            "targetPackage": package_name,
            "package": package_name,
        },
        deps = [
            native.package_relative_label(":" + name + "-srcs"),
            Label("@android_test_deps//:junit_junit"),
            Label("@android_test_deps//:androidx_test_rules"),
            Label("@android_test_deps//:androidx_test_ext_junit"),
        ] + SANITIZER_SUPPORT_LIBS,
        testonly = True,
        assets = [
            native.package_relative_label(":" + name + "-assets"),
        ],
        resource_files = [
            Label("//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherResources"),
        ],
        assets_dir = name + "-assets",
        tags = ["manual"],
    )

    # to run the test, use --test_arg=--device_id=device-id
    android_instrumentation_test(
        name = name,
        visibility = visibility,
        test_app = native.package_relative_label(":" + name + "-test-app"),
        tags = tags + [TAG_ANDROID, "exclusive"],  # need to be exclusive to prevent parallel invocation on the same device
        size = size,
        timeout = timeout,
        target_compatible_with = target_compatible_with,
    )


android_mobile_test = macro(
    implementation = _android_mobile_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Source files for the Android mobile test.",
        ),
        "copts": attr.string_list(
            default = [],
            doc = "Compiler options for the Android mobile test.",
        ),
        "conlyopts": attr.string_list(
            default = [],
            doc = "C compiler options for the Android mobile test.",
        ),
        "cxxopts": attr.string_list(
            default = [],
            doc = "C++ compiler options for the Android mobile test.",
        ),
        "linkopts": attr.string_list(
            default = [],
            doc = "Linker options for the Android mobile test.",
        ),
        "deps": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Dependencies for the Android mobile test.",
        ),
        "args": attr.string_list(
            default = [],
            doc = "Arguments for the Android mobile test.",
            configurable = False,
        ),
        "tags": attr.string_list(
            default = [],
            doc = "Arguments for the Android mobile test.",
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
        "deploy_resources": attr.bool(
            default = False,
            doc = "If true, resources from 'data' will be deployed to internal storage before launching the test.",
            configurable = False,
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
            doc = "Compatibility constraints for the Android mobile test.",
        ),
    },
)
