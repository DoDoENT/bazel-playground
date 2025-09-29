load(":clang_flags.bzl", "clang_flags")

def _calculate_android_flags():
    _local_android_flags = dict(**clang_flags)
    _local_android_flags["linker_release_flags"] = [
        "-Wl,--no-undefined",
        "-Wl,-z,relro",
        "-Wl,-z,now",
        "-Wl,-z,nocopyreloc",
        "-Wl,--gc-sections",
        "-Wl,--icf=all",
    ]
    _local_android_flags["compiler_runtime_checks"] = []
    _local_android_flags["linker_runtime_checks"] = []
    return _local_android_flags

android_flags = _calculate_android_flags()
