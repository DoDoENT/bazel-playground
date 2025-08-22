load("@bazel_skylib//lib:selects.bzl", "selects")
load(":flags.bzl", "create_resolved_flags_conditions")

config_setting(
    name = "release",
    values = {
        "compilation_mode": "opt",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "devRelease",
    values = {
        "compilation_mode": "fastbuild",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "debug",
    values = {
        "compilation_mode": "dbg",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "using_clang",
    flag_values = {
        "@bazel_tools//tools/cpp:compiler": "clang",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "using_gcc",
    flag_values = {
        "@bazel_tools//tools/cpp:compiler": "gcc",
    },
    visibility = ["//visibility:public"],
)

selects.config_setting_group(
    name = "apple_platform",
    match_any = [
        "@platforms//os:macos",
        "@platforms//os:ios",
    ],
    visibility = ["//visibility:public"],
)

selects.config_setting_group(
    name = "sanitizer_build",
    match_any = [":debug", ":devRelease"],
    visibility = ["//visibility:public"],
)

selects.config_setting_group(
    name = "clang_linux",
    match_all = [":using_clang", "@platforms//os:linux"],
    visibility = ["//visibility:public"],
)

selects.config_setting_group(
    name = "gcc_linux",
    match_all = [":using_gcc", "@platforms//os:linux"],
    visibility = ["//visibility:public"],
)

create_resolved_flags_conditions()
