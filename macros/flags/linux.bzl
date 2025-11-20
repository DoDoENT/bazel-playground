load(":clang_flags.bzl", "clang_flags")
load(":gcc_compatible_flags.bzl", "gcc_compat_flags")

def _calculate_linux_flags(starting_flags):
    _linux_flags = dict(**starting_flags)
    _linux_flags["linker_release_flags"] = [
        "-Wl,--gc-sections",
    ]

    return _linux_flags

def _calculate_linux_clang_flags():
    _linux_clang_flags = _calculate_linux_flags(clang_flags)
    _linux_clang_flags["linker_runtime_checks"] = _linux_clang_flags["linker_runtime_checks"] + [
        "-lclang_rt.ubsan_standalone_cxx",
    ]
    _linux_clang_flags["compiler_optimize_for_speed"] = _linux_clang_flags["compiler_optimize_for_speed"] + [
        "-mllvm",
        "-polly",
    ]

    _linux_clang_flags["linker_cxx_static_runtime"] = [
        "-nodefaultlibs",
        "-Wl,-Bstatic",
        "-lc++",
        "-lc++abi",
        "-Wl,-Bdynamic",
        "-lgcc",
        "-lc",
        "-lm",
    ]

    return _linux_clang_flags

linux_clang_flags = _calculate_linux_clang_flags()

def _calculate_linux_gcc_flags():
    _linux_gcc_flags = _calculate_linux_flags(gcc_compat_flags)

    _linux_gcc_flags["linker_cxx_static_runtime"] = [
        "-static-libgcc",
        "-static-libstdc++",
    ]

    return _linux_gcc_flags

linux_gcc_flags = _calculate_linux_gcc_flags()
