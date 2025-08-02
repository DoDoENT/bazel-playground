
load("@rules_android//android:rules.bzl", "android_binary")
load("//test-support/android-test/android_instrumentation_test:android_instrumentation_test.bzl", "android_instrumentation_test")
load("//macros:mobile_library.bzl", "mobile_library")
load(":test_utils.bzl", "prepare_assets")
load(":constants.bzl", "TAG_ANDROID")

def _sanitize_name(name):
    """Sanitize the test name to ensure it is valid for Android."""
    return name.replace("-", "_").replace(".", "_")

def _sanitize_for_jni(sanitized_name):
    """Sanitize name further for purpose of JNI naming"""
    return sanitized_name.replace("_", "_1")

def _package_to_path(pkgName):
    """Convert java package name to path"""
    return pkgName.replace(".", "/")

def _generate_test_java_impl(ctx):
    pkg_name = ctx.attr.package
    output_file = ctx.actions.declare_file(_package_to_path(pkg_name) + "/GoogleTestLauncher.java")

    substitutions = {
        "%(package)s": pkg_name,
        "%(testArgs)s": 'new String[]{' + ",".join(['"' + x + '"' for x in ctx.attr.test_args]) + '}',
        "%(nativeLibrary)s": ctx.attr.native_lib,
    }

    ctx.actions.expand_template(
        output = output_file,
        template = ctx.file._src_template,
        substitutions = substitutions,
    )

    return [
        DefaultInfo(files = depset([output_file])),
    ]

_generate_test_java = rule(
    implementation = _generate_test_java_impl,
    # output_to_genfiles = True,
    attrs = {
        "package": attr.string(mandatory = True, doc = "package for generated class"),
        "test_args": attr.string_list(mandatory = True, doc = "test arguments"),
        "native_lib": attr.string(mandatory = True, doc = "native lib name"),
        "_src_template": attr.label(
            allow_single_file = True,
            default = "//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherJavaTemplateSources",
        )
    },
)

def _android_mobile_test_impl(name, visibility, srcs, copts, deps, args, tags, data):
    sanitized_name = _sanitize_name(name)

    mobile_library(
        name = name + "-android-srcs",
        srcs = srcs + [
            "//test-support/android-test/GoogleTestLauncher:GoogleTestLauncherCppSources",
        ],
        deps = deps,
        copts = copts,
        testonly = True,
        alwayslink = True,
        linkstatic = False,
        local_defines = [
            "JNI_PREFIX=com_example_" + _sanitize_for_jni(sanitized_name) + "_test_GoogleTestLauncher",
        ],
        linkopts = [
            "-landroid",
            "-llog",
        ],
        tags = ["manual"],
    )

    _generate_test_java(
        name = name + "-java-srcs",
        package = "com.example." + sanitized_name + ".test",
        test_args = args,
        native_lib = name + "-test-app",
        tags = ["manual"],
    )

    prepare_assets(
        name = name + "-assets",
        data = data
    )

    android_binary(
        name = name + "-test-app",
        srcs = [
            ":" + name + "-java-srcs",
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
        assets = [
            ":" + name + "-assets",
        ],
        assets_dir = name + "-assets",
        tags = ["manual"],
    )

    # to run the test, use --test_arg=--device_id=device-id
    android_instrumentation_test(
        name = name,
        test_app = ":" + name + "-test-app",
        tags = tags + [TAG_ANDROID, "exclusive"],  # need to be exclusive to prevent parallel invocation on the same device
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
