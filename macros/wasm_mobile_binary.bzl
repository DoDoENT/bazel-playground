load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template_rule")

load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")
load(":test_utils.bzl", "prepare_assets", "collect_dependencies")


max_number_of_wasm_workers = 16

def _wasm_mobile_binary_impl(name, visibility, data, threads, simd, html_shell, **kwargs):
    wasm_linkopts = []
    additional_linker_inputs = []

    # TODO: Create XHR file system for data files
    if len(data) > 0:
        prepare_assets(
            name = name + "-assets",
            data = data
        )
        additional_linker_inputs.append(native.package_relative_label(":" + name + "-assets"))
        wasm_linkopts.append("--preload-file")
        wasm_linkopts.append("$(BINDIR)/" + native.package_name() + "/" + name + "-assets@/")

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
    defines = kwargs.pop("defines") or select({
        Label("//conditions:default"): [],
    })
    local_defines = kwargs.pop("local_defines") or select({
        Label("//conditions:default"): [],
    })
    provided_additional_linker_inputs = kwargs.pop("additional_linker_inputs") or select({
        Label("//conditions:default"): [],
    })

    outputs = [
        name + "/" + name + "-cc.wasm",
        name + "/" + name + "-cc.js",
    ]

    if threads:
        wasm_linkopts.append("-s PTHREAD_POOL_SIZE='Math.min( navigator.hardwareConcurrency, " + str(max_number_of_wasm_workers) + ")'")

    if html_shell:
        additional_linker_inputs.append(Label("//macros/wasm-helpers:wasm_worker_init"))
        wasm_linkopts.append("--pre-js")
        wasm_linkopts.append("$(execpath //macros/wasm-helpers:wasm_worker_init)")

        expand_template_rule(
            name = name + "-html-shell",
            template = Label("//macros/wasm-helpers:wasm_html_shell_template"),
            substitutions = {
                "${MB_TARGET_NAME}": name + "-cc",
            },
            out = name + "/" + name + "-cc.html",
            visibility = ["//visibility:private"],
        )

    if data:
        outputs.append(name + "/" + name + "-cc.data")

    cc_binary(
        name = name + "-cc",
        srcs = kwargs.pop("srcs") + [
            Label("//macros/wasm-helpers:wasm_thread_limit_helper"),
        ],
        linkopts = default_linkopts + wasm_linkopts + linkopts,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        conlyopts = default_conlyopts + conlyopts,
        defines = defines,
        local_defines = local_defines + [
            "EMSCRIPTEN_EMRUN_MAX_NUMBER_OF_WORKERS=" + str(max_number_of_wasm_workers),
        ],
        additional_linker_inputs = additional_linker_inputs + provided_additional_linker_inputs,
        **kwargs,
    )

    wasm_cc_binary(
        name = name + "-wasmcc",
        cc_target = native.package_relative_label(":" + name + "-cc"),
        simd = simd,
        threads = "off" if not threads else "emscripten",
        outputs = outputs,
        tags = ["manual"],
        testonly = True,
    )

    final_deps = [
        native.package_relative_label(":" + name + "-wasmcc"),
    ]
    if html_shell:
        final_deps.append(native.package_relative_label(":" + name + "-html-shell"))

    collect_dependencies(
        name = name,
        deps = final_deps,
        visibility = visibility,
        testonly = True,
    )

wasm_mobile_binary = macro(
    implementation = _wasm_mobile_binary_impl,
    inherit_attrs = native.cc_binary,
    attrs = {
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "List of data files to be packaged with the binary.",
            configurable = False,
        ),
        "threads": attr.bool(
            default = False,
            doc = "Enable pthreads support via emscripten.",
            configurable = False,
        ),
        "simd": attr.bool(
            default = False,
            doc = "Enable SIMD support via emscripten.",
            configurable = False,
        ),
        "html_shell": attr.bool(
            default = True,
            doc = "Generate an HTML shell file to run the WebAssembly binary.",
            configurable = False,
        ),
    },
)
