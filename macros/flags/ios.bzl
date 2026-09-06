load(":apple.bzl", "apple_flags")
load(":clang_flags.bzl", "clang_flags")

def _calculate_ios_flags():
    _local_ios_flags = dict(**apple_flags)
    _local_ios_flags["compiler_runtime_checks"] = []
    _local_ios_flags["linker_runtime_checks"] = []

    _local_ios_flags["linker_lto"] = clang_flags["linker_lto"] + [
        "-Wl,-mllvm,-threads=4",
    ]
    return _local_ios_flags

ios_flags = _calculate_ios_flags()
