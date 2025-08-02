load(":clang_flags.bzl", "clang_flags")

def _calculate_apple_flags():
    apple_flags = dict(**clang_flags)
    apple_flags["linker_release_flags"] = [
        "-Wl,-dead_strip",
    ]

    return apple_flags

apple_flags = _calculate_apple_flags()
