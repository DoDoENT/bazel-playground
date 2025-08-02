load(":clang_flags.bzl", "LINKOPTS_CLANG_LINUX_UBSAN")
load(":gcc_compatible_flags.bzl", "COPTS")

COMMON_COPTS = COPTS

COMMON_LINKOPTS = select({
    "//macros/flags:clang_linux_sanitizer_build": LINKOPTS_CLANG_LINUX_UBSAN,
    "//conditions:default": [],
})

