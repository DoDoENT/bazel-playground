load(":android.bzl", "android_flags")
load(":apple.bzl", "apple_flags")
load(":linux.bzl", "linux_clang_flags")
load(":emscripten.bzl", "emscripten_flags")

def _transform_to_select(key):
    return select({
        "@platforms//os:android": android_flags.get(key, default = []),
        ":apple_platform": apple_flags.get(key, default = []),
        ":clang_linux": linux_clang_flags.get(key, default = []),
        "@platforms//os:emscripten": emscripten_flags.get(key, default = []),
        "//conditions:default": [],
    })

flags = {
    "compiler_debug_symbols": _transform_to_select("compiler_debug_symbols"),
    "compiler_debug_flags": _transform_to_select("compiler_debug_flags"),
    "compiler_lto": _transform_to_select("compiler_lto"),
    "compiler_disable_lto": _transform_to_select("compiler_disable_lto"),
    "linker_lto": _transform_to_select("linker_lto"),
    "compiler_fast_math": _transform_to_select("compiler_fast_math"),
    "compiler_precise_math": _transform_to_select("compiler_precise_math"),
    "cxx_compiler_rtti_on": _transform_to_select("cxx_compiler_rtti_on"),
    "cxx_compiler_rtti_off": _transform_to_select("cxx_compiler_rtti_off"),
    "cxx_compiler_exceptions_on": _transform_to_select("cxx_compiler_exceptions_on"),
    "cxx_compiler_exceptions_off": _transform_to_select("cxx_compiler_exceptions_off"),
    "linker_exceptions_on": _transform_to_select("linker_exceptions_on"),
    "linker_exceptions_off": _transform_to_select("linker_exceptions_off"),
    "compiler_optimize_for_speed": _transform_to_select("compiler_optimize_for_speed"),
    "compiler_optimize_for_size": _transform_to_select("compiler_optimize_for_size"),
    "cxx_compiler_thread_safe_init": _transform_to_select("cxx_compiler_thread_safe_init"),
    "cxx_compiler_no_thread_safe_init": _transform_to_select("cxx_compiler_no_thread_safe_init"),
    "compiler_report_optimization": _transform_to_select("compiler_report_optimization"),
    "compiler_release_flags": _transform_to_select("compiler_release_flags"),
    "compiler_default_warnings": _transform_to_select("compiler_default_warnings"),
    "compiler_warnings_as_errors": _transform_to_select("compiler_warnings_as_errors"),
    "compiler_native_optimization": _transform_to_select("compiler_native_optimization"),
    "compiler_coverage": _transform_to_select("compiler_coverage"),
    "c_compiler_standard": _transform_to_select("c_compiler_standard"),
    "cxx_compiler_standard": _transform_to_select("cxx_compiler_standard"),
    "compiler_common_flags": _transform_to_select("compiler_common_flags"),
    "cxx_compiler_common_flags": _transform_to_select("cxx_compiler_common_flags"),
    "linker_common_flags": _transform_to_select("linker_common_flags"),
    "compiler_runtime_checks": _transform_to_select("compiler_runtime_checks"),
    "linker_runtime_checks": _transform_to_select("linker_runtime_checks"),
    "linker_coverage": _transform_to_select("linker_coverage"),
    "linker_assertions": _transform_to_select("linker_assertions"),
    "linker_release_flags": _transform_to_select("linker_release_flags"),
}

