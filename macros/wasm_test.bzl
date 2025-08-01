load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("@aspect_rules_js//js:defs.bzl", "js_test")

def _prepare_assets_impl(ctx):
    output_dir = ctx.label.name
    outputs = []
    for dep in ctx.attr.data:
        for file in dep.files.to_list():
            output = ctx.actions.declare_file("%s/%s" % (output_dir, file.path))
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )
            outputs.append(output)
    return [DefaultInfo(files = depset(outputs))]

_prepare_assets = rule(
    implementation = _prepare_assets_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
    }
)

def _wasm_test_impl(name, visibility, srcs, copts, deps, threads, simd, args, tags, data):

    preload_linkopts = []
    additional_linker_inputs = []

    if data:
        _prepare_assets(
            name = name + "-assets",
            data = data
        )
        additional_linker_inputs.append(name + "-assets")
        preload_linkopts.append("--preload-file")
        preload_linkopts.append("$(BINDIR)/" + native.package_name() + "/" + name + "-assets@/")

    cc_binary(
        name = name + "-cc",
        srcs = srcs,
        copts = copts,
        deps = deps,
        additional_linker_inputs = additional_linker_inputs,
        linkopts = preload_linkopts,
        testonly = True,
    )
    outputs = [
        name + "-bin/" + name + "-cc.wasm",
        name + "-bin/" + name + "-cc.js",
    ]
    if data:
        outputs.append(name + "-bin/" + name + "-cc.data")

    wasm_cc_binary(
        name = name + "-bin",
        cc_target = name + "-cc",
        simd = simd,
        threads = "off" if not threads else "emscripten",
        outputs = outputs,
        tags = ["manual"],
        testonly = True,
    )

    js_test(
        name = name,
        visibility = visibility,
        tags = tags,
        entry_point = name + "-bin/" + name + "-cc.js",
        data = outputs,
        args = args,
        chdir = native.package_name() + "/" + name + "-bin",
    )


wasm_test = macro(
    implementation = _wasm_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Source files for the Android mobile test.",
        ),
        "copts": attr.string_list(
            default = [],
            doc = "Compiler options for the Android mobile test.",
        ),
        "deps": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Dependencies for the Android mobile test.",
        ),
        "threads": attr.bool(
            default = False,
        ),
        "simd": attr.bool(
            default = False,
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
        ),
    },
)
