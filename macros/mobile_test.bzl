load("//macros:ios_mobile_test.bzl", "ios_mobile_test")
load("//macros:android_mobile_test.bzl", "android_mobile_test")
load("//macros:wasm_test.bzl", "wasm_test")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load("//macros/flags:flags.bzl", "COMMON_LINKOPTS")
load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_ADVANCED",
    "TAG_WASM_ADVANCED_THREADS",
    "TAG_HOST",
)

def _mobile_test_impl(name, visibility, **kwargs):
    copts = kwargs.pop("copts") or select({
        "//conditions:default": [],
    })
    linkopts = kwargs.pop("linkopts")
    deps = kwargs.pop("deps") or select({
        "//conditions:default": [],
    })
    srcs = kwargs.pop("srcs") or select({
        "//conditions:default": [],
    })
    tags = kwargs.pop("tags") or []
    args = kwargs.pop("args") or []
    data = kwargs.pop("data") or []
    deps = deps + select({
        "//conditions:default": [
            "//test-support/paths:test-paths",
            "@googletest//:gtest_main",
        ]
    })
    cc_test(
        name = name,
        srcs = srcs,
        visibility = visibility,
        linkopts = COMMON_LINKOPTS + linkopts if linkopts else COMMON_LINKOPTS,
        deps = deps,
        tags = tags + [TAG_HOST],
        args = args,
        data = data,
        **kwargs,
    )
    ios_mobile_test(
        name = name + "-ios",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        tags = tags,
        args = args,
        data = data,
    )
    android_mobile_test(
        name = name + "-android",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        tags = tags,
        args = args,
        data = data,
    )
    wasm_test(
        name = name + "-wasm-basic",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        threads = False,
        simd = False,
        args = args,
        tags = tags + [TAG_WASM_BASIC],
        data = data,
    )
    wasm_test(
        name = name + "-wasm-advanced",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        threads = False,
        simd = True,
        args = args,
        tags = tags + [TAG_WASM_ADVANCED],
        data = data,
    )
    wasm_test(
        name = name + "-wasm-advanced-threads",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        threads = True,
        simd = True,
        args = args,
        tags = tags + [TAG_WASM_ADVANCED_THREADS],
        data = data,
    )


mobile_test = macro(
    implementation = _mobile_test_impl,
    inherit_attrs = native.cc_test,
    attrs = {
        "args": attr.string_list(
            default = [],
            doc = "Arguments for the iOS mobile test.",
            configurable = False,
        ),
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Test data files",
            configurable = False,
        ),
    }
)

