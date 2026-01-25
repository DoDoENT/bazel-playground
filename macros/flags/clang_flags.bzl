load(":gcc_compatible_flags.bzl", "gcc_compat_flags")

def _calculate_clang_flags():
    _local_clang_flags = dict(**gcc_compat_flags)
    _local_clang_flags["compiler_lto"] = [
        "-flto=thin",
        # "-fwhole-program-vtables", # needs toolchain support
    ]
    _local_clang_flags["linker_lto"] = [
        "-flto=thin",
    ]
    _local_clang_flags["compiler_optimize_for_speed"] = _local_clang_flags["compiler_optimize_for_speed"] + [
        "-fvectorize",
        "-fslp-vectorize",
    ]
    _local_clang_flags["compiler_optimize_for_size"] = [
        "-Oz",
    ]
    _local_clang_flags["compiler_report_optimization"] =  _local_clang_flags["compiler_report_optimization"] + [
        "-Rpass=loop-.*",
    ]
    _local_clang_flags["compiler_default_warnings"] = _local_clang_flags["compiler_default_warnings"] + [
        "-Wdocumentation",
        "-Wheader-guard",
        "-Wno-error=#warnings",
        "-Wno-error=unknown-attributes",
        "-Wno-unused-command-line-argument",
        "-Wno-vla-cxx-extension",
        "-Wno-missing-field-initializers",
    ]
    _local_clang_flags["compiler_common_flags"] = _local_clang_flags["compiler_common_flags"] + [
        "-fenable-matrix",
    ]
    _local_clang_flags["compiler_runtime_checks"] = [
        # "-fsanitize=address",
        # "-fsanitize=undefined",
        # "-fsanitize=signed-integer-overflow",
        # "-fsanitize=integer-divide-by-zero",
    ]
    _local_clang_flags["linker_runtime_checks"] = _local_clang_flags["compiler_runtime_checks"]
    _local_clang_flags["compiler_coverage"] = _local_clang_flags["compiler_coverage"] + [
        "-fprofile-instr-generate",
        "-fcoverage-mapping",
    ]
    _local_clang_flags["linker_coverage"] = [
        "-fprofile-instr-generate",
    ]

    return _local_clang_flags

clang_flags = _calculate_clang_flags()
