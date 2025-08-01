load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("//macros/flags:flags.bzl", "COMMON_LINKOPTS")

def _mobile_binary_impl(name, visibility, **kwargs):
    linkopts = kwargs.pop("linkopts")
    cc_binary(
        name = name,
        visibility = visibility,
        linkopts = COMMON_LINKOPTS + linkopts if linkopts else COMMON_LINKOPTS,
        **kwargs,
    )
    wasm_cc_binary(
        name = name + "-wasm-basic",
        cc_target = name,
        visibility = visibility,
        simd = False,
        threads = "off",
        outputs = [
            name + "-wasm-basic/" + name + ".wasm",
            name + "-wasm-basic/" + name + ".js",
        ],
    )
    wasm_cc_binary(
        name = name + "-wasm-advanced",
        cc_target = name,
        visibility = visibility,
        simd = True,
        threads = "off",
        outputs = [
            name + "-wasm-advanced/" + name + ".wasm",
            name + "-wasm-advanced/" + name + ".js",
        ],
    )
    wasm_cc_binary(
        name = name + "-wasm-advanced-threads",
        cc_target = name,
        visibility = visibility,
        simd = True,
        threads = "emscripten",
        outputs = [
            name + "-wasm-advanced-threads/" + name + ".wasm",
            name + "-wasm-advanced-threads/" + name + ".js",
        ],
    )


mobile_binary = macro(
    inherit_attrs = native.cc_binary,
    implementation = _mobile_binary_impl,
)
