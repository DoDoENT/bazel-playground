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
            config_group_name = config_group_name_prefix + str(counter)

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
            "P:N_1": ["A", "C"],
            "P:N_2": ["B", "C"],
        },
        flat_select_dict = {
            "P:N_1": ["a3", "b4"],
            "P:N_2": ["bla2"],
            "A": ["a", "a2"],
        },
    )
    input2 = struct(
        config_setting_groups = {
            "P:N_1": ["B", "D", "E"],
            "P:N_2": ["B", "D", "F"],
            "P:N_3": ["B", "C"],
        },
        flat_select_dict = {
            "P:N_1": ["bla"],
            "P:N_2": ["bar"],
            "P:N_3": ["-l1", "-l2"],
            "B": ["samob"],
        },
    )

    expected = struct(
        config_setting_groups = {
            "P:N_1": ["A", "C", "B", "D", "E"],
            "P:N_2": ["A", "C", "B", "D", "F"],
            "P:N_3": ["B", "C", "D", "E"],
            "P:N_4": ["B", "C", "D", "F"],
            "P:N_5": ["A", "B", "D", "E"],
            "P:N_6": ["A", "B", "D", "F"],
            "P:N_7": ["A", "C", "B"],
            "P:N_8": ["B", "C"],
            "P:N_9": ["A", "B"],
        },
        flat_select_dict = {
            "P:N_1": ["a3", "b4", "bla"],
            "P:N_2": ["a3", "b4", "bar"],
            "P:N_3": ["bla2", "bla"],
            "P:N_4": ["bla2", "bar"],
            "P:N_5": ["a", "a2", "bla"],
            "P:N_6": ["a", "a2", "bar"],
            "P:N_7": ["a3", "b4", "-l1", "-l2"],
            "P:N_8": ["bla2", "-l1", "-l2"],
            "P:N_9": ["a", "a2", "samob"],
        },
    )

    asserts.equals(
        env = env,
        expected = expected,
        actual = concat_flattened(name = "N", package = "P", first_flattened = input1, second_flattened = input2),
        msg = "Concatenating select dicts failed",
    )

    return unittest.end(env)

concatenate_flattened_test = unittest.make(_concatenate_test_impl)

def _concat_select_dicts_impl(ctx):
    env = unittest.begin(ctx)

    linker_common_flags = {
        "@platforms//os:emscripten": [
            "-s MALLOC=emmalloc",
            "-s STRICT=1",
        ],
        "//conditions:default": [],
    }
    linker_runtime_checks = {
        "@platforms//os:emscripten": [
            "-s ASSERTIONS=2",
            "-s STACK_OVERFLOW_CHECK=2",
            "-s GL_ASSERTIONS=1",
            "-s SAFE_HEAP=1",
        ],
        "@platforms//os:android": [],
        "@platforms//os:ios": [],
        "@platforms//os:macos": [
            "-fsanitize=address",
            "-fsanitize=undefined",
        ],
        "@platforms//os:linux": [
            "-fsanitize=address",
            "-fsanitize=undefined",
            "-lclang_rt.ubsan_standalone_cxx",
        ],
    }
    linker_release_flags = {
        "@platforms//os:android": [
            "-Wl,--no-undefined",
            "-Wl,-z,relro",
            "-Wl,-z,now",
            "-Wl,-z,nocopyreloc",
            "-Wl,--gc-sections",
            "-Wl,--icf=all",
        ],
        "@platforms//os:emscripten": [
            "-s ASSERTIONS=0",
            "-s STACK_OVERFLOW_CHECK=0",
            "--closure 1",
            "-s IGNORE_CLOSURE_COMPILER_ERRORS=1",
        ],
        "@platforms//os:ios": [
            "-Wl,-dead_strip",
        ],
        "@platforms//os:macos": [
            "-Wl,-dead_strip",
        ],
        "@platforms//os:linux": [
            "-Wl,--gc-sections",
        ],
    }

    linker_flags = concat_select_dicts(
        "linker_flags_conditions",
        "//macros/flags",
        linker_common_flags,
        {
            ":debug": linker_runtime_checks,
            ":devRelease": linker_runtime_checks,
            ":release": linker_release_flags,
        }
    )

    expected = struct(
        config_setting_groups = {
            "//macros/flags:linker_flags_conditions_1": ["@platforms//os:emscripten", ":debug"],
            "//macros/flags:linker_flags_conditions_2": ["@platforms//os:emscripten", ":devRelease"],
            "//macros/flags:linker_flags_conditions_3": ["@platforms//os:emscripten", ":release"],
            "//macros/flags:linker_flags_conditions_4": [":debug", "@platforms//os:android"],
            "//macros/flags:linker_flags_conditions_5": [":debug", "@platforms//os:ios"],
            "//macros/flags:linker_flags_conditions_6": [":debug", "@platforms//os:macos"],
            "//macros/flags:linker_flags_conditions_7": [":debug", "@platforms//os:linux"],
            "//macros/flags:linker_flags_conditions_8": [":devRelease", "@platforms//os:android"],
            "//macros/flags:linker_flags_conditions_9": [":devRelease", "@platforms//os:ios"],
            "//macros/flags:linker_flags_conditions_10": [":devRelease", "@platforms//os:macos"],
            "//macros/flags:linker_flags_conditions_11": [":devRelease", "@platforms//os:linux"],
            "//macros/flags:linker_flags_conditions_12": [":release", "@platforms//os:android"],
            "//macros/flags:linker_flags_conditions_13": [":release", "@platforms//os:ios"],
            "//macros/flags:linker_flags_conditions_14": [":release", "@platforms//os:macos"],
            "//macros/flags:linker_flags_conditions_15": [":release", "@platforms//os:linux"]
        },
        flat_select_dict = {
            "//macros/flags:linker_flags_conditions_1": ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=2", "-s STACK_OVERFLOW_CHECK=2", "-s GL_ASSERTIONS=1", "-s SAFE_HEAP=1"],
            "//macros/flags:linker_flags_conditions_2": ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=2", "-s STACK_OVERFLOW_CHECK=2", "-s GL_ASSERTIONS=1", "-s SAFE_HEAP=1"],
            "//macros/flags:linker_flags_conditions_3": ["-s MALLOC=emmalloc", "-s STRICT=1", "-s ASSERTIONS=0", "-s STACK_OVERFLOW_CHECK=0", "--closure 1", "-s IGNORE_CLOSURE_COMPILER_ERRORS=1"],
            "//macros/flags:linker_flags_conditions_4": [],
            "//macros/flags:linker_flags_conditions_5": [],
            "//macros/flags:linker_flags_conditions_6": ["-fsanitize=address", "-fsanitize=undefined"],
            "//macros/flags:linker_flags_conditions_7": ["-fsanitize=address", "-fsanitize=undefined", "-lclang_rt.ubsan_standalone_cxx"],
            "//macros/flags:linker_flags_conditions_8": [],
            "//macros/flags:linker_flags_conditions_9": [],
            "//macros/flags:linker_flags_conditions_10": ["-fsanitize=address", "-fsanitize=undefined"],
            "//macros/flags:linker_flags_conditions_11": ["-fsanitize=address", "-fsanitize=undefined", "-lclang_rt.ubsan_standalone_cxx"],
            "//macros/flags:linker_flags_conditions_12": ["-Wl,--no-undefined", "-Wl,-z,relro", "-Wl,-z,now", "-Wl,-z,nocopyreloc", "-Wl,--gc-sections", "-Wl,--icf=all"],
            "//macros/flags:linker_flags_conditions_13": ["-Wl,-dead_strip"],
            "//macros/flags:linker_flags_conditions_14": ["-Wl,-dead_strip"],
            "//macros/flags:linker_flags_conditions_15": ["-Wl,--gc-sections"]
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
