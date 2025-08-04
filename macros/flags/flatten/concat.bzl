load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:partial.bzl", "partial")

load("//macros:constants.bzl", "TAG_STARLARK")
load(":sanitize.bzl", "sanitize_flattened")

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

def _concat_flatten_test_suite_impl(name, visibility):
    unittest.suite(
        name,
        partial.make(concatenate_flattened_test, tags = [TAG_STARLARK]),
    )

concat_test_suite = macro(
    implementation = _concat_flatten_test_suite_impl,
)
