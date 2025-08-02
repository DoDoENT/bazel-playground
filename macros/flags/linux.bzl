load(":clang_flags.bzl", "clang_flags")

def _calculate_linux_flags(starting_flags):
    linux_flags = dict(**starting_flags)
    linux_flags["linker_release_flags"] = [
        "-Wl,--gc-sections",
    ]

    return linux_flags

def _calculate_linux_clang_flags():
    linux_clang_flags = _calculate_linux_flags(clang_flags)
    linux_clang_flags["linuxlinker_runtime_checks"].extend([
        "-lclang_rt.ubsan_standalone_cxx",
    ])

    return linux_clang_flags

linux_clang_flags = _calculate_linux_clang_flags()
