load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "tool_path",
    "feature",
    "flag_group",
    "flag_set",
    "variable_with_value",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/clang",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = "/bin/false",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "/bin/false",
        ),
        tool_path(
            name = "objdump",
            path = "/bin/false",
        ),
        tool_path(
            name = "strip",
            path = "/bin/false",
        ),
    ]

    features = [
        feature(
            name = "archiver_flags",
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.cpp_link_static_library],
                    flag_groups = [
                        flag_group(flags = ["rcs"]),
                        flag_group(
                            flags = ["%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                    ],
                ),
                flag_set(
                    actions = [ACTION_NAMES.cpp_link_static_library],
                    flag_groups = [
                        flag_group(
                            iterate_over = "libraries_to_link",
                            flag_groups = [
                                flag_group(
                                    flags = ["%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file",
                                    ),
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.object_files}"],
                                    iterate_over = "libraries_to_link.object_files",
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                ),
                            ],
                            expand_if_available = "libraries_to_link",
                        ),
                    ],
                ),
            ]
        ),
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-lstdc++",
                            ]
                        ),
                    ],
                ),
            ]
        ),
        feature(
            name = "sanitizers",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fsanitize=address",
                                "-fsanitize=undefined",
                            ]
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "lto-full",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-flto",
                            ]
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "lto-thin",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-flto=thin",
                            ]
                        ),
                    ],
                ),
            ],
        )
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        cxx_builtin_include_directories = [
            "/Applications/Xcode-16.4.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1",
            "/Applications/Xcode-16.4.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/17/include",
            "/Applications/Xcode-16.4.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/17/share",
            "/Applications/Xcode-16.4.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include",
        ],
        features = features,
        toolchain_identifier = "mac_arm64_toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "arm64",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
