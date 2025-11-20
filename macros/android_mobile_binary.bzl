load("@rules_android//android:rules.bzl", "android_binary", "android_library")
load(":android_build_config.bzl", "android_build_config")
load(":android_utils.bzl", "SANITIZER_SUPPORT_LIBS")
load(":constants.bzl", "TAG_ANDROID")
load(":mobile_library.bzl", "mobile_library")
load(":test_utils.bzl", "prepare_assets", "remove_cc_binary_specific_attrs")


def _android_mobile_binary_impl(name, visibility, args, **kwargs):
    package_name = "com.example.exerunner"

    srcs = kwargs.pop("srcs") or select({
        Label("//conditions:default"): [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        Label("//conditions:default"): [],
    })
    deps = kwargs.pop("deps") or select({
        Label("//conditions:default"): [],
    })
    tags = kwargs.pop("tags") or []
    data = kwargs.pop("data") or []

    remove_cc_binary_specific_attrs(kwargs)

    mobile_library(
        name = name + "-srcs",
        srcs = srcs + [
            Label("//macros/android-helpers/exerunner:ExerunnerCppSources"),
        ],
        deps = deps + [
            Label("//macros/android-helpers/exerunner/PathProvider"),
        ],
        linkopts = linkopts + [
            "-landroid",
            "-llog",
        ],
        alwayslink = True,
        linkstatic = kwargs.pop("linkstatic") and False,
        tags = ["manual"],
        **kwargs
    )

    android_build_config(
        name = name + "-build-config",
        package = package_name,
        application_id = package_name,
        build_config_fields = {
            "NATIVE_LIB_NAME": ["String", '"' + name + '"'],
            "PKG_ROOT": ["String", '"' + native.package_name().split("/")[0] + '"'],
            "ARGS": ["String", '"' + " ".join([x for x in args]) + '"'],
        },
    )

    prepare_assets(
        name = name + "-assets",
        data = data
    )

    android_binary(
        name = name,
        visibility = visibility,
        srcs = [
            native.package_relative_label(":" + name + "-build-config"),
            Label("//macros/android-helpers/exerunner:ExerunnerJavaSources"),
        ],
        custom_package = package_name,
        manifest = Label("//macros/android-helpers/exerunner:ExerunnerManifest"),
        manifest_values = {
            "applicationId": package_name,
            "minSdkVersion": "21",
            "targetSdkVersion": "31",
            "package": package_name,
        },
        deps = [
            native.package_relative_label(":" + name + "-srcs"),
        ] + SANITIZER_SUPPORT_LIBS,
        testonly = kwargs.get("testonly"),
        assets = [
            native.package_relative_label(":" + name + "-assets"),
        ],
        resource_files = [
            Label("//macros/android-helpers/exerunner:ExerunnerResources"),
        ],
        assets_dir = name + "-assets",
        tags = tags + [TAG_ANDROID],
    )


android_mobile_binary = macro(
    implementation = _android_mobile_binary_impl,
    inherit_attrs = native.cc_binary,
    attrs = {
        "args": attr.string_list(
            default = [],
            configurable = False,
        ),
    },
)
