load(":gcc_compatible_flags.bzl", "gcc_compat_flags")

def _calculate_clang_flags():
    clang_flags = dict(**gcc_compat_flags)
    clang_flags["compiler_lto"] = [
        "-flto=thin",
        "-fwhole-program-vtables",
    ]
    clang_flags["linker_lto"] = [
        "-flto=thin",
    ]
    clang_flags["compiler_optimize_for_speed"].extend([
        "-fvectorize",
        "-fslp-vectorize",
    ])
    clang_flags["compiler_report_optimization"].extend([
        "-Rpass=loop-.*",
    ])
    clang_flags["compiler_default_warnings"].extend([
        "-Wdocumentation",
        "-Wheader-guard",
    ])
    clang_flags["compiler_common_flags"].extend([
        "-fenable-matrix",
    ])
    clang_flags["compiler_runtime_checks"] = [
        "-fsanitize=address",
        "-fsanitize=undefined",
        "-fsanitize=signed-integer-overflow",
        "-fsanitize=integer-divide-by-zero",
    ]
    clang_flags["linker_runtime_checks"] = clang_flags["compiler_runtime_checks"]
    clang_flags["compiler_coverage"].extend([
        "-fprofile-instr-generate",
        "-fcoverage-mapping",
    ])
    clang_flags["linker_coverage"] = [
        "-fprofile-instr-generate",
    ]

    return clang_flags

clang_flags = _calculate_clang_flags()
