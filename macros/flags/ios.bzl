load(":apple.bzl", "apple_flags")

def _calculate_ios_flags():
    ios_flags = dict(**apple_flags)
    ios_flags["compiler_runtime_checks"] = []
    ios_flags["linker_runtime_checks"] = []
    return ios_flags

ios_flags = _calculate_ios_flags()
