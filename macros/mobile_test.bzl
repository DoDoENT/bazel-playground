load("//macros/ios-test:ios_mobile_test.bzl", "ios_mobile_test")
load("@rules_cc//cc:cc_test.bzl", "cc_test")

def _mobile_test_impl(name, visibility, **kwargs):
    copts = kwargs.pop("copts") or select({
        "//conditions:default": [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        "//conditions:default": [],
    })
    deps = kwargs.pop("deps") or select({
        "//conditions:default": [],
    })
    srcs = kwargs.pop("srcs") or select({
        "//conditions:default": [],
    })
    tags = kwargs.pop("tags") or []
    cc_test(
        name = name,
        srcs = srcs,
        visibility = visibility,
        copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        linkopts = linkopts + select({
            "@platforms//os:linux": [
                "-Wl,-rpath,/usr/local/lib",
                "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu",
                "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"
            ],
            "//conditions:default": [],
        }),
        deps = deps + [
            "@googletest//:gtest_main",
        ],
        tags = tags + ["host"],
        **kwargs,
    )
    ios_mobile_test(
        name = name + "-ios",
        visibility = visibility,
        srcs = srcs,
        copts = copts,
        deps = deps,
        tags = tags,
    )


mobile_test = macro(
    implementation = _mobile_test_impl,
    inherit_attrs = native.cc_test,
)

