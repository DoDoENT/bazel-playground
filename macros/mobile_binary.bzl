load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")
load("//macros/flags:flags.bzl", "resolved_flags")

def _mobile_binary_impl(name, visibility, **kwargs):
    linkopts = kwargs.pop("linkopts") or select({
        "//conditions:default": [],
    })
    cc_binary(
        name = name,
        visibility = visibility,
        # linkopts = resolved_flags["linkopts"] + linkopts if linkopts else resolved_flags["linkopts"],
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
