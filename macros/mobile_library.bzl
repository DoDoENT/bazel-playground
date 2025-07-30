load("@rules_cc//cc:cc_library.bzl", "cc_library")

def _mobile_library_impl(name, visibility, **kwargs):
    cc_library(
        name = name,
        visibility = visibility,
        linkstatic = kwargs.pop("linkstatic", True),
        strip_include_prefix = kwargs.pop("strip_include_prefix") or "Include",
        **kwargs,
    )

mobile_library = macro(
    inherit_attrs = native.cc_library,
    implementation = _mobile_library_impl,
)

