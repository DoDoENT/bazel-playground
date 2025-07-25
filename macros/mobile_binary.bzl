load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")


def _mobile_binary_impl(name, visibility, **kwargs):
    copts = kwargs.pop("copts") or select({
        "//conditions:default": [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        "//conditions:default": [],
    })
    cc_binary(
        name = name,
        visibility = visibility,
        copts = copts + select({
            "//conditions:default": [],
            "//:release": ["-O3", "-flto"],
        }),
        linkopts = select({
            "@platforms//os:linux": [
                "-Wl,-rpath,/usr/local/lib",
                "-Wl,-rpath,/usr/local/lib/aarch64-unknown-linux-gnu",
                "-Wl,-rpath,/usr/local/lib/x86_64-unknown-linux-gnu"
            ],
            "//conditions:default": [],
        }),
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
        name = name + "-wasm-simd",
        cc_target = name,
        visibility = visibility,
        simd = True,
        threads = "off",
        outputs = [
            name + "-wasm-simd/" + name + ".wasm",
            name + "-wasm-simd/" + name + ".js",
        ],
    )
    wasm_cc_binary(
        name = name + "-wasm-threads",
        cc_target = name,
        visibility = visibility,
        simd = True,
        threads = "emscripten",
        outputs = [
            name + "-wasm-threads/" + name + ".wasm",
            name + "-wasm-threads/" + name + ".js",
        ],
    )


mobile_binary = macro(
    inherit_attrs = native.cc_binary,
    implementation = _mobile_binary_impl,
)
