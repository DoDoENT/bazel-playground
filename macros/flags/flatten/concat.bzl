load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:partial.bzl", "partial")

load("//macros:constants.bzl", "TAG_STARLARK")
load(":sanitize.bzl", "sanitize_flattened")
load(":flatten.bzl", "flatten_select_dict")

def concat_flattened(name, package, first_flattened, second_flattened):
    """Concatenates two flattened structures into one, generating a new
    flattened structure that represents the concatenation of lists across
    all possible branches.
    """
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = package + ":" + name + "_"
    counter = 0

    for key1 in first_flattened.flat_select_dict.keys():
        for key2 in second_flattened.flat_select_dict.keys():
            counter += 1
            config_group_name = Label(config_group_name_prefix + str(counter))

            # Combine the config setting groups
            combined_settings = (
                first_flattened.config_setting_groups.get(key1, [key1]) +
                second_flattened.config_setting_groups.get(key2, [key2])
            )
            config_setting_groups[config_group_name] = combined_settings

            # Combine the flat select dicts
            flat_select_dict[config_group_name] = (
                first_flattened.flat_select_dict[key1] +
                second_flattened.flat_select_dict[key2]
            )

    unsanitized_result = struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict,
    )

    return sanitize_flattened(
        name = name,
        package = package,
        input_flattened = unsanitized_result,
    )

def concat_select_dicts(name, package, *args):
    """Concatenates multiple select dicts into one, generating a new
    flattened structure that represents the concatenation of lists across
    all possible branches.
    Input dicts are first flattened using `flatten_select_dicts` function
    and then concatenated using `concat_flattened`.
    """
    if not args:
        return struct(
            config_setting_groups = {},
            flat_select_dict = {},
        )

    flattened_args = [
        flatten_select_dict(
            name = name,
            package = package,
            input_dict = arg,
        )
        for arg in args
    ]

    result = flattened_args[0]
    for i in range(1, len(flattened_args)):
        result = concat_flattened(
            name = name,
            package = package,
            first_flattened = result,
            second_flattened = flattened_args[i],
        )

    return result

######################
#      TESTS         #
######################

def _concatenate_test_impl(ctx):
    env = unittest.begin(ctx)

    input1 = struct(
        config_setting_groups = {
            Label("//P:N_1"): [Label(":A"), Label(":C")],
            Label("//P:N_2"): [Label(":B"), Label(":C")],
        },
        flat_select_dict = {
            Label("//P:N_1"): ["a3", "b4"],
            Label("//P:N_2"): ["bla2"],
            Label(":A"): ["a", "a2"],
        },
    )
    input2 = struct(
        config_setting_groups = {
            Label("//P:N_1"): [Label(":B"), Label(":D"), Label(":E")],
            Label("//P:N_2"): [Label(":B"), Label(":D"), Label(":F")],
            Label("//P:N_3"): [Label(":B"), Label(":C")],
        },
        flat_select_dict = {
            Label("//P:N_1"): ["bla"],
            Label("//P:N_2"): ["bar"],
            Label("//P:N_3"): ["-l1", "-l2"],
            Label(":B"): ["samob"],
        },
    )

    expected = struct(
        config_setting_groups = {
            Label("//P:N_1"): [Label(":A"), Label(":C"), Label(":B"), Label(":D"), Label(":E")],
            Label("//P:N_2"): [Label(":A"), Label(":C"), Label(":B"), Label(":D"), Label(":F")],
            Label("//P:N_3"): [Label(":B"), Label(":C"), Label(":D"), Label(":E")],
            Label("//P:N_4"): [Label(":B"), Label(":C"), Label(":D"), Label(":F")],
            Label("//P:N_5"): [Label(":A"), Label(":B"), Label(":D"), Label(":E")],
            Label("//P:N_6"): [Label(":A"), Label(":B"), Label(":D"), Label(":F")],
            Label("//P:N_7"): [Label(":A"), Label(":C"), Label(":B")],
            Label("//P:N_8"): [Label(":B"), Label(":C")],
            Label("//P:N_9"): [Label(":A"), Label(":B")],
        },
        flat_select_dict = {
            Label("//P:N_1"): ["a3", "b4", "bla"],
            Label("//P:N_2"): ["a3", "b4", "bar"],
            Label("//P:N_3"): ["bla2", "bla"],
            Label("//P:N_4"): ["bla2", "bar"],
            Label("//P:N_5"): ["a", "a2", "bla"],
            Label("//P:N_6"): ["a", "a2", "bar"],
            Label("//P:N_7"): ["a3", "b4", "-l1", "-l2"],
            Label("//P:N_8"): ["bla2", "-l1", "-l2"],
            Label("//P:N_9"): ["a", "a2", "samob"],
        },
    )

    asserts.equals(
        env = env,
        expected = expected,
        actual = concat_flattened(name = "N", package = "//P", first_flattened = input1, second_flattened = input2),
        msg = "Concatenating select dicts failed",
    )

    return unittest.end(env)

concatenate_flattened_test = unittest.make(_concatenate_test_impl)

def _concat_select_dicts_impl(ctx):
    env = unittest.begin(ctx)

    linker_common_flags = {
        Label("@platforms//os:emscripten"): [
            "-s MALLOC=emmalloc",
            "-s STRICT=1",
        ],
        Label("//conditions:default"): [],
    }
    linker_runtime_checks = {
        Label("@platforms//os:emscripten"): [
            "-s ASSERTIONS=2",
            "-s STACK_OVERFLOW_CHECK=2",
            "-s GL_ASSERTIONS=1",
            "-s SAFE_HEAP=1",
        ],
        Label("@platforms//os:android"): [],
        Label("@platforms//os:ios"): [],
        Label("@platforms//os:macos"): [
            "-fsanitize=address",
            "-fsanitize=undefined",
        ],
        Label("@platforms//os:linux"): [
            "-fsanitize=address",
            "-fsanitize=undefined",
            "-lclang_rt.ubsan_standalone_cxx",
        ],
    }
    linker_release_flags = {
        Label("@platforms//os:android"): [
            "-Wl,--no-undefined",
            "-Wl,-z,relro",
            "-Wl,-z,now",
            "-Wl,-z,nocopyreloc",
            "-Wl,--gc-sections",
            "-Wl,--icf=all",
        ],
        Label("@platforms//os:emscripten"): [
            "-s ASSERTIONS=0",
            "-s STACK_OVERFLOW_CHECK=0",
            "--closure 1",
            "-s IGNORE_CLOSURE_COMPILER_ERRORS=1",
        ],
        Label("@platforms//os:ios"): [
            "-Wl,-dead_strip",
        ],
        Label("@platforms//os:macos"): [
            "-Wl,-dead_strip",
        ],
        Label("@platforms//os:linux"): [
            "-Wl,--gc-sections",
        ],
    }

    linker_flags = concat_select_dicts(
        "linker_flags_conditions",
        "//macros/flags",
        linker_common_flags,
        {
            Label(":debug"): linker_runtime_checks,
            Label(":devRelease"): linker_runtime_checks,
            Label(":release"): linker_release_flags,
        }
    )

    expected = struct(
        config_setting_groups = {
            Label("//macros/flags:linker_flags_conditions_1"): [Label("@platforms//os:emscripten"), Label(":debug")],
            Label("//macros/flags:linker_flags_conditions_2"): [Label("@platforms//os:emscripten"), Label(":devRelease")],
            Label("//macros/flags:linker_flags_conditions_3"): [Label("@platforms//os:emscripten"), Label(":release")],
            Label("//macros/flags:linker_flags_conditions_4"): [Label(":debug"), Label("@platforms//os:android")],
            Label("//macros/flags:linker_flags_conditions_5"): [Label(":debug"), Label("@platforms//os:ios")],
            Label("//macros/flags:linker_flags_conditions_6"): [Label(":debug"), Label("@platforms//os:macos")],
            Label("//macros/flags:linker_flags_conditions_7"): [Label(":debug"), Label("@platforms//os:linux")],
            Label("//macros/flags:linker_flags_conditions_8"): [Label(":devRelease"), Label("@platforms//os:android")],
            Label("//macros/flags:linker_flags_conditions_9"): [Label(":devRelease"), Label("@platforms//os:ios")],
            Label("//macros/flags:linker_flags_conditions_10"): [Label(":devRelease"), Label("@platforms//os:macos")],
            Label("//macros/flags:linker_flags_conditions_11"): [Label(":devRelease"), Label("@platforms//os:linux")],
            Label("//macros/flags:linker_flags_conditions_12"): [Label(":release"), Label("@platforms//os:android")],
            Label("//macros/flags:linker_flags_conditions_13"): [Label(":release"), Label("@platforms//os:ios")],
            Label("//macros/flags:linker_flags_conditions_14"): [Label(":release"), Label("@platforms//os:macos")],
            Label("//macros/flags:linker_flags_conditions_15"): [Label(":release"), Label("@platforms//os:linux")]
        },
        flat_select_dict = {
            Label("//macros/flags:linker_flags_conditions_1"): ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=2", "-s STACK_OVERFLOW_CHECK=2", "-s GL_ASSERTIONS=1", "-s SAFE_HEAP=1"],
            Label("//macros/flags:linker_flags_conditions_2"): ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=2", "-s STACK_OVERFLOW_CHECK=2", "-s GL_ASSERTIONS=1", "-s SAFE_HEAP=1"],
            Label("//macros/flags:linker_flags_conditions_3"): ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=0", "-s STACK_OVERFLOW_CHECK=0", "--closure 1", "-s IGNORE_CLOSURE_COMPILER_ERRORS=1"],
            Label("//macros/flags:linker_flags_conditions_4"): [],
            Label("//macros/flags:linker_flags_conditions_5"): [],
            Label("//macros/flags:linker_flags_conditions_6"): ["-fsanitize=address", "-fsanitize=undefined"],
            Label("//macros/flags:linker_flags_conditions_7"): ["-fsanitize=address", "-fsanitize=undefined", "-lclang_rt.ubsan_standalone_cxx"],
            Label("//macros/flags:linker_flags_conditions_8"): [],
            Label("//macros/flags:linker_flags_conditions_9"): [],
            Label("//macros/flags:linker_flags_conditions_10"): ["-fsanitize=address", "-fsanitize=undefined"],
            Label("//macros/flags:linker_flags_conditions_11"): ["-fsanitize=address", "-fsanitize=undefined", "-lclang_rt.ubsan_standalone_cxx"],
            Label("//macros/flags:linker_flags_conditions_12"): ["-Wl,--no-undefined", "-Wl,-z,relro", "-Wl,-z,now", "-Wl,-z,nocopyreloc", "-Wl,--gc-sections", "-Wl,--icf=all"],
            Label("//macros/flags:linker_flags_conditions_13"): ["-Wl,-dead_strip"],
            Label("//macros/flags:linker_flags_conditions_14"): ["-Wl,-dead_strip"],
            Label("//macros/flags:linker_flags_conditions_15"): ["-Wl,--gc-sections"]
        }
    )

    asserts.equals(
        env = env,
        expected = expected,
        actual = linker_flags,
        msg = "Concatenating select dicts failed",
    )

    return unittest.end(env)

concat_select_dicts_test = unittest.make(_concat_select_dicts_impl)

def _concat_flatten_test_suite_impl(name, visibility):
    unittest.suite(
        name,
        partial.make(concatenate_flattened_test, tags = [TAG_STARLARK]),
        partial.make(concat_select_dicts_test, tags = [TAG_STARLARK]),
    )

concat_test_suite = macro(
    implementation = _concat_flatten_test_suite_impl,
)
