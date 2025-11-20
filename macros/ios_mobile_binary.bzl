load("@rules_apple//apple:ios.bzl", "ios_application")
load("@rules_apple//apple:resources.bzl", "apple_resource_group")

load(":mobile_library.bzl", "mobile_library")
load(":constants.bzl", "TAG_IOS")
load(":test_utils.bzl", "remove_cc_binary_specific_attrs")

def _ios_mobile_binary_impl(name, visibility, args, **kwargs):
    deps = kwargs.pop("deps") or select({
        Label("//conditions:default"): [],
    })
    tags = kwargs.pop("tags") or []
    data = kwargs.pop("data") or []

    remove_cc_binary_specific_attrs(kwargs)

    mobile_library(
        name = name + "-srcs",
        deps = deps + [
            Label("//macros/ios-helpers:ios-bundle-path-provider"),
        ],
        alwayslink = True,
        linkstatic = kwargs.pop("linkstatic") and False,
        tags = ["manual"],
        **kwargs,
    )

    apple_resource_group(
        name = name + "-resources",
        structured_resources = data,
    )

    ios_application(
        name = name,
        bundle_id = "com.example." + name,
        visibility = visibility + ["//visibility:public"],
        deps = [
            native.package_relative_label(":" + name + "-srcs"),
        ],
        minimum_os_version = "15.0",
        provisioning_profile = Label("//test-support/ios-test:xcode_profile"),
        tags = tags + [TAG_IOS],
        families = [
            "iphone",
            "ipad",
        ],
        infoplists = [Label("//macros/ios-helpers:info-plist")],
        testonly = kwargs.get("testonly"),
        resources = [
            native.package_relative_label(":" + name + "-resources")
        ],
    )


ios_mobile_binary = macro(
    implementation = _ios_mobile_binary_impl,
    inherit_attrs = native.cc_binary,
    attrs = {
        "args": attr.string_list(
            default = [],
            configurable = False,
        ),
    },
)
