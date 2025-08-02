load("@bazel_skylib//lib:selects.bzl", "selects")
load(":gcc_compatible_flags.bzl", "COPTS")

LINKOPTS_CLANG_LINUX_UBSAN = [
    "-lclang_rt.ubsan_standalone_cxx",
]

