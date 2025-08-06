load("@bazel_skylib//lib:selects.bzl", "selects")

load(":android.bzl", "android_flags")
load(":emscripten.bzl", "emscripten_flags")
load(":ios.bzl", "ios_flags")
load(":linux.bzl", "linux_clang_flags", "linux_gcc_flags")
load(":macos.bzl", "macos_flags")

load("//macros/flags/flatten:flatten.bzl", "flatten_select_dict")
load("//macros/flags/flatten:flat_config_groups.bzl", "create_config_setting_groups")
load("//macros/flags/flatten:concat.bzl", "concat_select_dicts")

def _transform_to_select_dict(key):
    return {
        Label("@platforms//os:android"): android_flags.get(key, default = []),
        Label("@platforms//os:ios"): ios_flags.get(key, default = []),
        Label("@platforms//os:macos"): macos_flags.get(key, default = []),
        Label("//macros/flags:clang_linux"): linux_clang_flags.get(key, default = []),
        Label("//macros/flags:gcc_linux"): linux_gcc_flags.get(key, default = []),
        Label("@platforms//os:emscripten"): emscripten_flags.get(key, default = []),
    }

""" Resolves flags for different platforms and compilers.
    The keys are the names of the flags, and the values are dictionaries
    that map platform labels to lists of flags. These dictionaries
    can be used with `select()` to apply the appropriate flags.
"""
flags_dicts = {
    "compiler_debug_symbols": _transform_to_select_dict("compiler_debug_symbols"),
    "compiler_debug_flags": _transform_to_select_dict("compiler_debug_flags"),
    "compiler_lto": _transform_to_select_dict("compiler_lto"),
    "compiler_disable_lto": _transform_to_select_dict("compiler_disable_lto"),
    "linker_lto": _transform_to_select_dict("linker_lto"),
    "compiler_fast_math": _transform_to_select_dict("compiler_fast_math"),
    "compiler_precise_math": _transform_to_select_dict("compiler_precise_math"),
    "cxx_compiler_rtti_on": _transform_to_select_dict("cxx_compiler_rtti_on"),
    "cxx_compiler_rtti_off": _transform_to_select_dict("cxx_compiler_rtti_off"),
    "cxx_compiler_exceptions_on": _transform_to_select_dict("cxx_compiler_exceptions_on"),
    "cxx_compiler_exceptions_off": _transform_to_select_dict("cxx_compiler_exceptions_off"),
    "linker_exceptions_on": _transform_to_select_dict("linker_exceptions_on"),
    "linker_exceptions_off": _transform_to_select_dict("linker_exceptions_off"),
    "compiler_optimize_for_speed": _transform_to_select_dict("compiler_optimize_for_speed"),
    "compiler_optimize_for_size": _transform_to_select_dict("compiler_optimize_for_size"),
    "cxx_compiler_thread_safe_init": _transform_to_select_dict("cxx_compiler_thread_safe_init"),
    "cxx_compiler_no_thread_safe_init": _transform_to_select_dict("cxx_compiler_no_thread_safe_init"),
    "compiler_report_optimization": _transform_to_select_dict("compiler_report_optimization"),
    "compiler_release_flags": _transform_to_select_dict("compiler_release_flags"),
    "compiler_default_warnings": _transform_to_select_dict("compiler_default_warnings"),
    "compiler_warnings_as_errors": _transform_to_select_dict("compiler_warnings_as_errors"),
    "compiler_native_optimization": _transform_to_select_dict("compiler_native_optimization"),
    "compiler_coverage": _transform_to_select_dict("compiler_coverage"),
    "c_compiler_standard": _transform_to_select_dict("c_compiler_standard"),
    "cxx_compiler_standard": _transform_to_select_dict("cxx_compiler_standard"),
    "compiler_common_flags": _transform_to_select_dict("compiler_common_flags"),
    "cxx_compiler_common_flags": _transform_to_select_dict("cxx_compiler_common_flags"),
    "linker_common_flags": _transform_to_select_dict("linker_common_flags"),
    "compiler_runtime_checks": _transform_to_select_dict("compiler_runtime_checks"),
    "linker_runtime_checks": _transform_to_select_dict("linker_runtime_checks"),
    "linker_coverage": _transform_to_select_dict("linker_coverage"),
    "linker_release_flags": _transform_to_select_dict("linker_release_flags"),
}

resolved_flags_select_dicts = {
    "linkopts": concat_select_dicts(
        "linkopts_conditions",
        "//macros/flags",
        flags_dicts["linker_common_flags"],
        flags_dicts["linker_exceptions_off"],
        selects.with_or_dict({
            (Label(":debug"), Label(":devRelease")): flags_dicts["linker_runtime_checks"],
            Label(":release"): flags_dicts["linker_release_flags"],
        }),
        {
            Label(":release"): flags_dicts["linker_lto"],
            Label("//conditions:default"): [],
        },
    ),
    "conlyopts": concat_select_dicts(
        "conlyopts_conditions",
        "//macros/flags",
        flags_dicts["c_compiler_standard"],
    ),
    "copts": concat_select_dicts(
        "copts_conditions",
        "//macros/flags",
        flags_dicts["compiler_common_flags"],
        flags_dicts["compiler_default_warnings"],
        flags_dicts["compiler_warnings_as_errors"],
        flags_dicts["compiler_debug_symbols"],
        {
            Label(":debug"): flags_dicts["compiler_debug_flags"],
            Label(":devRelease"): flags_dicts["compiler_debug_flags"],
            Label(":release"): flags_dicts["compiler_release_flags"],
        },
        {
            Label(":release"): flags_dicts["compiler_lto"],
            Label("//conditions:default"): [],
        },
        {
            Label(":release"): flags_dicts["compiler_optimize_for_size"],
            Label("//conditions:default"): [],
        },
    ),
    "cxxopts": concat_select_dicts(
        "cxxopts_conditions",
        "//macros/flags",
        flags_dicts["cxx_compiler_common_flags"],
        flags_dicts["cxx_compiler_standard"],
        flags_dicts["cxx_compiler_no_thread_safe_init"],
        flags_dicts["cxx_compiler_exceptions_off"],
        selects.with_or_dict({
            (Label(":debug"), Label(":devRelease")): flags_dicts["cxx_compiler_rtti_on"],
            Label(":release"): flags_dicts["cxx_compiler_rtti_off"],
        }),
    ),
}

def create_resolved_flags_conditions():
    for value in resolved_flags_select_dicts.values():
        create_config_setting_groups(
            config_setting_groups = value.config_setting_groups,
        )
