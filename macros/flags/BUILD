load("@bazel_skylib//lib:selects.bzl", "selects")
load(":flags.bzl", "create_resolved_flags_conditions")

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

config_setting(
    name = "using_gcc",
    flag_values = {
        "@bazel_tools//tools/cpp:compiler": "gcc",
    },
)

selects.config_setting_group(
    name = "apple_platform",
    match_any = [
        "@platforms//os:macos",
        "@platforms//os:ios",
    ],
)

selects.config_setting_group(
    name = "sanitizer_build",
    match_any = [":debug", ":devRelease"]
)

selects.config_setting_group(
    name = "clang_linux",
    match_all = [":using_clang", "@platforms//os:linux"]
)

create_resolved_flags_conditions()
