load(":clang_flags.bzl", "clang_flags")
load(":gcc_compatible_flags.bzl", "gcc_compat_flags")

def _calculate_linux_flags(starting_flags):
    linux_flags = dict(**starting_flags)
    linux_flags["linker_release_flags"] = [
        "-Wl,--gc-sections",
    ]

    return linux_flags

def _calculate_linux_clang_flags():
    linux_clang_flags = _calculate_linux_flags(clang_flags)
    linux_clang_flags["linker_runtime_checks"] = linux_clang_flags["linker_runtime_checks"] + [
        "-lclang_rt.ubsan_standalone_cxx",
    ]

    return linux_clang_flags

linux_clang_flags = _calculate_linux_clang_flags()

def _calculate_linux_gcc_flags():
    linux_gcc_flags = _calculate_linux_flags(gcc_compat_flags)

    return linux_gcc_flags

linux_gcc_flags = _calculate_linux_gcc_flags()
