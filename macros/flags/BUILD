load("@bazel_skylib//lib:selects.bzl", "selects")

config_setting(
    name = "release",
    values = {
        "compilation_mode": "opt",
    },
)

config_setting(
    name = "devRelease",
    values = {
        "compilation_mode": "fastbuild",
    },
)

config_setting(
    name = "debug",
    values = {
        "compilation_mode": "dbg",
    },
)

config_setting(
    name = "using_clang",
    flag_values = {
        "@bazel_tools//tools/cpp:compiler": "clang",
    },
)

selects.config_setting_group(
    name = "sanitizer_build",
    match_any = [":debug", ":devRelease"]
)

selects.config_setting_group(
    name = "clang_linux_sanitizer_build",
    match_all = [":sanitizer_build", ":using_clang", "//platforms/os:linux"]
)
