gcc_compat_flags = {
    "compiler_debug_symbols": [
        "-g",
    ],
    "compiler_debug_flags": [
        "-O0",
        "-DDEBUG",
        "-D_DEBUG",
    ],
    "compiler_lto": [
        "-flto",
    ],
    "compiler_disable_lto": [
        "-fno-lto",
    ],
    "linker_lto": [
        "-flto",
    ],
    "compiler_fast_math": [
        "-ffast-math",
        "-ffp-contract=fast",
    ],
    "compiler_precise_math": [
        "-fno-fast-math",
        "-ffp-contract=off",
    ],
    "cxx_compiler_rtti_on": [
        "-frtti",
    ],
    "cxx_compiler_rtti_off": [
        "-fno-rtti",
    ],
    "cxx_compiler_exceptions_on": [
        "-fexceptions",
    ],
    "cxx_compiler_exceptions_off": [
        "-fno-exceptions",
    ],
    "compiler_optimize_for_speed": [
        "-O3",
        "-funroll-loops",
    ],
    "compiler_optimize_for_size": [
        "-Os",
    ],
    "cxx_compiler_thread_safe_init": [
        "-fthreadsafe-statics",
    ],
    "cxx_compiler_no_thread_safe_init": [
        "-fno-threadsafe-statics",
    ],
    "compiler_report_optimization": [
        "-ftree-vectorizer-verbose=6",
    ],
    "compiler_dev_release_flags": [
        "-DALLOW_ASSERT_IN_RELEASE",
        "-DBOOST_ENABLE_ASSERT_HANDLER",
        "-UNDEBUG",
        "-funwind-tables",
        "-fasynchronous-unwind-tables",
    ],
    "compiler_release_flags": [
        "-fomit-frame-pointer",
        "-ffunction-sections",
        "-fmerge-all-constants",
        "-fno-stack-protector",
        "-DNDEBUG",
        "-fno-unwind-tables",
        "-fno-asynchronous-unwind-tables",
    ],
    "compiler_default_warnings": [
        "-Wall",
        "-Wextra",
        "-Wconversion",
        "-Wstrict-aliasing",
        "-Wno-error=deprecated-declarations",
    ],
    "compiler_warnings_as_errors": [
        "-Werror",
    ],
    "compiler_native_optimization": [
        "-march=native",
        "-mtune=native",
    ],
    "compiler_coverage": [
        "-fprofile-arcs",
        "-ftest-coverage",
    ],
    "c_compiler_standard": [
        "-std=gnu11",
    ],
    "cxx_compiler_standard": [
        "-std=gnu++2b",
    ],
    "compiler_common_flags": [
        "-fstrict-aliasing",
        "-fvisibility=hidden",
        "-fPIC",
    ],
    "cxx_compiler_common_flags": [
        "-fstrict-enums",
        "-fvisibility-inlines-hidden",
    ],
}
