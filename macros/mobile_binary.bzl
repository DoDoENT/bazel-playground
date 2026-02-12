load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")

load(":wasm_mobile_binary.bzl", "wasm_mobile_binary")
load(":mobile_library.bzl", "mobile_library")
load(":android_mobile_binary.bzl", "android_mobile_binary")
load(":ios_mobile_binary.bzl", "ios_mobile_binary")
load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_SIMD",
    "TAG_WASM_SIMD_THREADS",
    "TAG_HOST",
)

def _mobile_binary_impl(name, visibility, data, args, host_only, static_cxx_runtime, **kwargs):
    mobile_library(
        name = name + "-paths",
        srcs = [
            Label("//test-support/paths:test-paths-impl"),
        ],
        local_defines = [
            'PKG_NAME=\\"' + native.package_name() + '\\"',
        ],
        deps = [
            Label("//test-support/paths:test-paths"),
        ],
    )

    deps = kwargs.pop("deps") or select({
        Label("//conditions:default"): [],
    })
    srcs = kwargs.pop("srcs") or select({
        Label("//conditions:default"): [],
    })
    tags = kwargs.pop("tags") or []
    default_conlyopts = select(resolved_flags_select_dicts["conlyopts"].flat_select_dict)
    default_copts = select(resolved_flags_select_dicts["copts"].flat_select_dict)
    default_cxxopts = select(resolved_flags_select_dicts["cxxopts"].flat_select_dict)

    default_linkopts = select(resolved_flags_select_dicts["linkopts"].flat_select_dict)
    if static_cxx_runtime:
        default_linkopts += select(resolved_flags_select_dicts["linker_cxx_static_runtime"].flat_select_dict)

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
    defines = kwargs.pop("defines") or select({
        Label("//conditions:default"): [],
    })
    includes = kwargs.pop("includes") or select({
        Label("//conditions:default"): [],
    })
    local_defines = kwargs.pop("local_defines") or select({
        Label("//conditions:default"): [],
    })
    linkstatic = kwargs.pop("linkstatic")
    if linkstatic == None:
        linkstatic = True  # Default to static linking if not specified

    cc_binary(
        name = name,
        srcs = srcs,
        visibility = visibility,
        linkopts = default_linkopts + linkopts,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        conlyopts = default_conlyopts + conlyopts,
        deps = deps + [
            native.package_relative_label(":" + name + "-paths"),
        ],
        includes = includes + [
            "Source",
        ],
        tags = tags + [TAG_HOST],
        data = data,
        defines = defines,
        local_defines = local_defines,
        linkstatic = linkstatic,
        args = args,
        **kwargs,
    )
    if not host_only:
        # Note: iOS, Android, and Wasm will internally add default copts, cxxopts, and linkopts

        # TODO: implement iOS and Android mobile exe runners
        ios_mobile_binary(
            name = name + "-ios",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            includes = includes + [
                "Source",
            ],
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
            **kwargs,
        )

        android_mobile_binary(
            name = name + "-android",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            includes = includes + [
                "Source",
            ],
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
            **kwargs,
        )

        wasm_mobile_binary(
            name = name + "-wasm-basic",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            tags = tags,
            data = data,
            defines = defines,
            includes = includes,
            local_defines = local_defines,
            simd = False,
            threads = False,
            **kwargs
        )
        wasm_mobile_binary(
            name = name + "-wasm-simd",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            tags = tags,
            data = data,
            defines = defines,
            includes = includes,
            local_defines = local_defines,
            simd = True,
            threads = False,
            **kwargs
        )
        wasm_mobile_binary(
            name = name + "-wasm-simd-threads",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            tags = tags,
            data = data,
            defines = defines,
            includes = includes,
            local_defines = local_defines,
            simd = True,
            threads = True,
            **kwargs
        )


mobile_binary = macro(
    implementation = _mobile_binary_impl,
    inherit_attrs = native.cc_binary,
    attrs = {
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Test data files",
            configurable = False,
        ),
        "args": attr.string_list(
            default = [],
            configurable = False,
        ),
        "host_only": attr.bool(
            default = False,
            doc = "If true, only define the host version of the binary.",
            configurable = False,
        ),
        "static_cxx_runtime": attr.bool(
            default = False,
            doc = "If true, link the C++ runtime statically in release build.",
            configurable = False,
        ),
    }
)
