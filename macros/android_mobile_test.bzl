
load("@rules_android//android:rules.bzl", "android_binary")
load("//test-support/android-test/android_instrumentation_test:android_instrumentation_test.bzl", "android_instrumentation_test")
load("//macros:mobile_library.bzl", "mobile_library")

def _sanitize_name(name):
    """Sanitize the test name to ensure it is valid for Android."""
    return name.replace("-", "_").replace(".", "_")


def _android_mobile_test_impl(name, visibility, srcs, copts, deps, args, tags, data):
    mobile_library(
        name = name + "-android-srcs",
        srcs = srcs + [
            "//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherCppSources",
        ],
        deps = deps,
        testonly = True,
        linkstatic = False
    )

    sanitized_name = _sanitize_name(name)

    android_binary(
        name = name + "-test-app",
        srcs = [
            "//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherJavaSources",
        ],
        manifest = "//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherManifest",
        manifest_values = {
            "applicationId": "com.example." + sanitized_name + ".test",
            "minSdkVersion": "21",
            "targetSdkVersion": "31",
            "targetPackage": "com.example." + sanitized_name + ".test",
        },
        deps = [
            name + "-android-srcs",
            "@maven//:junit_junit",
            "@maven//:androidx_test_rules",
            "@maven//:androidx_test_ext_junit",
        ],
        testonly = True,
        assets = data,
    )

    # to run the test, use --test_arg=--device_id=device-id
    android_instrumentation_test(
        name = name,
        test_app = ":" + name + "-test-app",
        tags = tags + ["android", "exclusive"],  # need to be exclusive to prevent parallel invocation on the same device
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
    },
)
