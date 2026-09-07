load(":clang_flags.bzl", "clang_flags")

def _calculate_apple_flags():
    _local_apple_flags = dict(**clang_flags)
    _local_apple_flags["linker_release_flags"] = [
        "-Wl,-dead_strip",
        "-Wl,-x",
    ]

    _local_apple_flags["linker_lto"] = _local_apple_flags["linker_lto"] + [

        # used with LLVM toolchain
        "-Wl,--thinlto-jobs=4",

        # used with Xcode toolchain
        # "-Wl,-mllvm,-threads=4",
    ]

    return _local_apple_flags

apple_flags = _calculate_apple_flags()
