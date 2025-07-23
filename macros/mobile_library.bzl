load("@rules_cc//cc:cc_library.bzl", "cc_library")

def _mobile_library_impl(name, visibility, **kwargs):
    copts = kwargs.pop("copts") or select({
        "//conditions:default": [],
    })
    cc_library(
        name = name,
        visibility = visibility,
        copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        linkstatic = kwargs.pop("linkstatic", True),
        **kwargs,
    )

mobile_library = macro(
    inherit_attrs = native.cc_library,
    implementation = _mobile_library_impl,
)

