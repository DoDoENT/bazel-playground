load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load(":test_utils.bzl", "prepare_assets")
load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")
load(":wasm_mobile_binary.bzl", "wasm_mobile_binary")
load("//test-support/wasm-test/posluznik-test:posluznik_test.bzl", "posluznik_test")

def _wasm_test_impl(name, visibility, srcs, copts, conlyopts, cxxopts, linkopts, deps, threads, simd, args, tags, data, defines, local_defines):
    wasm_mobile_binary(
        name = name + "-bin",
        srcs = srcs,
        data = data,
        simd = simd,
        threads = threads,
        tags = ["manual"],
        testonly = True,
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
        deps = deps,
        defines = defines,
        local_defines = local_defines,
    )

    posluznik_test(
        name = name,
        visibility = visibility,
        tags = tags,
        wasm_mobile_binary = native.package_relative_label(":" + name + "-bin"),
        args = args,
    )


wasm_test = macro(
    implementation = _wasm_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Source files for the WebAssembly mobile test.",
        ),
        "copts": attr.string_list(
            default = [],
            doc = "Compiler options for the WebAssembly mobile test.",
        ),
        "conlyopts": attr.string_list(
            default = [],
            doc = "C compiler options for the WebAssembly mobile test.",
        ),
        "cxxopts": attr.string_list(
            default = [],
            doc = "C++ compiler options for the WebAssembly mobile test.",
        ),
        "linkopts": attr.string_list(
            default = [],
            doc = "Linker options for the WebAssembly mobile test.",
        ),
        "deps": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Dependencies for the WebAssembly mobile test.",
        ),
        "threads": attr.bool(
            default = False,
            configurable = False,
        ),
        "simd": attr.bool(
            default = False,
            configurable = False,
        ),
        "args": attr.string_list(
            default = [],
            configurable = False,
        ),
        "tags": attr.string_list(
            default = [],
            configurable = False,
        ),
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Test data files",
            configurable = False,
        ),
        "defines": attr.string_list(
            default = [],
            doc = "Preprocessor defines for the Android mobile test.",
        ),
        "local_defines": attr.string_list(
            default = [],
            doc = "Preprocessor defines for the Android mobile test that should not be propagated to dependents.",
        ),
    },
)
