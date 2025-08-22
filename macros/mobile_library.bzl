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
    additional_compiler_inputs = kwargs.pop("additional_compiler_inputs") or select({
        Label("//conditions:default"): [],
    })
    linkstatic = kwargs.pop("linkstatic")
    if linkstatic == None:
        linkstatic = True  # Default to static linking if not specified
    testonly = kwargs.pop("testonly")
    if testonly == None:
        testonly = False

    if not testonly:
        banned_compiler_inputs = select({
            Label("//conditions:default"): [
                Label("//build-helper:banned-header"),
            ],
        })
        force_include_copts = [
            "-include", "$(location //build-helper:banned-header)",
        ]
    else:
        banned_compiler_inputs = select({
            Label("//conditions:default"): [],
        })
        force_include_copts = []
    cc_library(
        name = name,
        visibility = visibility,
        copts = default_copts + copts + force_include_copts,
        additional_compiler_inputs = additional_compiler_inputs + banned_compiler_inputs,
        cxxopts = default_cxxopts + cxxopts,
        linkstatic = linkstatic,
        strip_include_prefix = kwargs.pop("strip_include_prefix") or "Include",
        testonly = testonly,
        **kwargs,
    )

mobile_library = macro(
    inherit_attrs = native.cc_library,
    implementation = _mobile_library_impl,
)

