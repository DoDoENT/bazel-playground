filegroup(name = "empty")

cc_toolchain(
    name = "mac_arm64_toolchain",
    toolchain_identifier = "mac_arm64_toolchain",
    toolchain_config = ":mac_arm64_toolchain_config",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "cc_toolchain_for_mac_arm64",
    toolchain = ":mac_arm64_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    exec_compatible_with = [
        "@platforms//os:macos",
        "@platforms//cpu:arm64",
    ],
    target_compatible_with = [
        "@platforms//os:macos",
        "@platforms//cpu:arm64",
    ],
)

package(default_visibility = ["//visibility:public"])

load(":cc_toolchain_config.bzl", "cc_toolchain_config")

cc_toolchain_config(name = "mac_arm64_toolchain_config")
