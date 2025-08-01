load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("@aspect_rules_js//js:defs.bzl", "js_test")

def _wasm_test_impl(name, visibility, cc_host_test, threads, simd, args, tags, data):
    wasm_cc_binary(
        name = name + "-bin",
        cc_target = cc_host_test,
        visibility = ["//visibility:public"],
        simd = simd,
        threads = "off" if not threads else "emscripten",
        outputs = [
            name + "-bin/" + cc_host_test.name + "-bin.wasm",
            name + "-bin/" + cc_host_test.name + "-bin.js",
        ],
        tags = ["manual"],
        testonly = True,
    )

    js_test(
        name = name,
        args = args,
        tags = tags,
        data = data,
        entry_point = name + "-bin/" + cc_host_test.name + "-bin.js",
    )


wasm_test = macro(
    implementation = _wasm_test_impl,
    attrs = {
        "cc_host_test": attr.label(
            mandatory = True,
            configurable = False,
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
