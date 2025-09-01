load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")
load("//macros:wasm_mobile_binary.bzl", "wasm_mobile_binary")
load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_ADVANCED",
    "TAG_WASM_ADVANCED_THREADS",
    "TAG_HOST",
)

def _mobile_binary_impl(name, visibility, **kwargs):
    tags = kwargs.pop("tags") or []

    default_conlyopts = select(resolved_flags_select_dicts["conlyopts"].flat_select_dict)
    default_copts = select(resolved_flags_select_dicts["copts"].flat_select_dict)
    default_cxxopts = select(resolved_flags_select_dicts["cxxopts"].flat_select_dict)
    default_linkopts = select(resolved_flags_select_dicts["linkopts"].flat_select_dict)
    conlyopts = kwargs.pop("conlyopts") or select({
        Label("//conditions:default"): []
    })
    copts = kwargs.pop("copts") or select({
        Label("//conditions:default"): [],
    })
    cxxopts = kwargs.pop("cxxopts") or select({
        Label("//conditions:default"): [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        Label("//conditions:default"): [],
    })
    cc_binary(
        name = name,
        visibility = visibility,
        linkopts = default_linkopts + linkopts if linkopts else default_linkopts,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        conlyopts = default_conlyopts + conlyopts,
        tags = tags + [TAG_HOST],
        **kwargs,
    )

    # TODO: iOS and Android exe runners

    wasm_mobile_binary(
        name = name + "-wasm-basic",
        visibility = visibility,
        simd = False,
        threads = False,
        copts = copts,
        cxxopts = cxxopts,
        conlyopts = conlyopts,
        **kwargs
    )
    wasm_mobile_binary(
        name = name + "-wasm-advanced",
        visibility = visibility,
        simd = True,
        threads = False,
        copts = copts,
        cxxopts = cxxopts,
        conlyopts = conlyopts,
        **kwargs
    )
    wasm_mobile_binary(
        name = name + "-wasm-advanced-threads",
        visibility = visibility,
        simd = True,
        threads = True,
        copts = copts,
        cxxopts = cxxopts,
        conlyopts = conlyopts,
        **kwargs
    )


mobile_binary = macro(
    inherit_attrs = native.cc_binary,
    implementation = _mobile_binary_impl,
)
