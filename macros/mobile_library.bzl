load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")

def _mobile_library_impl(name, visibility, **kwargs):
    default_copts = select(resolved_flags_select_dicts["copts"].flat_select_dict)
    default_cxxopts = select(resolved_flags_select_dicts["cxxopts"].flat_select_dict)
    copts = kwargs.pop("copts") or select({
        Label("//conditions:default"): [],
    })
    cxxopts = kwargs.pop("cxxopts") or select({
        Label("//conditions:default"): [],
    })
    cc_library(
        name = name,
        visibility = visibility,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        linkstatic = kwargs.pop("linkstatic", True),
        strip_include_prefix = kwargs.pop("strip_include_prefix") or "Include",
        **kwargs,
    )

mobile_library = macro(
    inherit_attrs = native.cc_library,
    implementation = _mobile_library_impl,
)

