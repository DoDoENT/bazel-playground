load(":clang_flags.bzl", "clang_flags")

def _calculate_android_flags():
    android_flags = dict(**clang_flags)
    android_flags["linker_release_flags"] = [
        "-Wl,--no-undefined",
        "-Wl,-z,relro",
        "-Wl,-z,now",
        "-Wl,-z,nocopyreloc",
        "-Wl,--gc-sections",
        "-Wl,--icf=all",
    ]
    android_flags["compiler_runtime_checks"] = []
    android_flags["linker_runtime_checks"] = []
    return android_flags

android_flags = _calculate_android_flags()
