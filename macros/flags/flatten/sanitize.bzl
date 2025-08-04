load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:partial.bzl", "partial")

load("//macros:constants.bzl", "TAG_STARLARK")

def sanitize_flattened(name, package, input_flattened, unique_prefixes = ["@platforms//os", "@platforms//cpu"]):
    """Sanitizes the flattened structure by reordering entries in a way
       that those with more conditions are before those with less conditions.
       Thus, more specialized conditions are always preferred to more general
       ones. Relative order of entries with same number of conditions is
       left unchanged.
       Additionally, duplicate propositions in config_setting_groups are removed
       The input and output of the function is the structure described in
       `flatten_select_dicts` function.
    """
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = package + ":" + name + "_"
    counter = 0

    unified_setting_groups = dict()
    seen = set()
    removed_keys = set()

    # first remove all duplicate conditions in config_setting_groups
    for key in input_flattened.config_setting_groups.keys():
        unique_settings = set(input_flattened.config_setting_groups[key])
        if len(unique_settings) > 1:
            unique_settings.discard("//conditions:default")
        impossible_combination = False
        for prefix in unique_prefixes:
            count = 0
            for setting in unique_settings:
                if setting.startswith(prefix):
                    count += 1
                    if count > 1:
                        impossible_combination = True
                        break
        stringified = " ".join(sorted(unique_settings))
        if stringified in seen or impossible_combination:
            removed_keys.add(key)
        else:
            seen.add(stringified)
            unified_setting_groups[key] = list(unique_settings)

    setting_group_keys = sorted(
        unified_setting_groups.keys(),
        key = lambda k: len(unified_setting_groups[k]),
        reverse = True
    )

    old_new_key_map = dict()

    for key in setting_group_keys:
        counter += 1
        config_group_name = config_group_name_prefix + str(counter)

        config_setting_groups[config_group_name] = unified_setting_groups[key]
        flat_select_dict[config_group_name] = input_flattened.flat_select_dict[key]
        old_new_key_map[key] = config_group_name

    # finally copy the remaining entries
    for key in input_flattened.flat_select_dict.keys():
        if key not in flat_select_dict and key not in removed_keys and old_new_key_map.get(key) not in flat_select_dict:
            flat_select_dict[key] = input_flattened.flat_select_dict[key]

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict,
    )


def _sanitize_order_impl(ctx):
    env = unittest.begin(ctx)

    input = struct(
        config_setting_groups = {
            "P:N_1": ["condition1", "A"],
            "P:N_2": ["condition1", "B", "C"],
            "P:N_3": ["condition1", "B", "D", "E"],
            "P:N_4": ["condition1", "B", "D", "F"],
        },
        flat_select_dict = {
            "P:N_1": ["-bla", "-bla2"],
            "P:N_2": ["-l1", "-l2"],
            "P:N_3": ["bla"],
            "P:N_4": ["bar"],
            "condition2": ["default"],
        },
    )

    expected = struct(
        config_setting_groups = {
            "P:N_1": ["condition1", "B", "D", "E"],
            "P:N_2": ["condition1", "B", "D", "F"],
            "P:N_3": ["condition1", "B", "C"],
            "P:N_4": ["condition1", "A"],
        },
        flat_select_dict = {
            "P:N_1": ["bla"],
            "P:N_2": ["bar"],
            "P:N_3": ["-l1", "-l2"],
            "P:N_4": ["-bla", "-bla2"],
            "condition2": ["default"],
        },
    )

    asserts.equals(
        env = env,
        expected = expected,
        actual = sanitize_flattened(name = "N", package = "P", input_flattened = input),
        msg = "Flattening select dicts failed",
    )

    return unittest.end(env)

sanitize_flattened_order_test = unittest.make(_sanitize_order_impl)

def _sanitize_order_duplicates_impl(ctx):
    env = unittest.begin(ctx)

    input = struct(
        config_setting_groups = {
            "P:N_1": ["A", "C", "B", "D", "E"],
            "P:N_2": ["A", "C", "B", "D", "F"],
            "P:N_3": ["A", "C", "B", "C"],
            "P:N_4": ["A", "C", "B"],
            "P:N_5": ["B", "C", "B", "D", "E"],
            "P:N_6": ["B", "C", "B", "D", "F"],
            "P:N_7": ["B", "C", "B", "C"],
            "P:N_8": ["B", "C", "B"],
            "P:N_9": ["A", "B", "D", "E"],
            "P:N:10": ["A", "B", "D", "F"],
            "P:N_11": ["A", "B", "C"],
            "P:N_12": ["A", "B"],
        },
        flat_select_dict = {
            "P:N_1": ["a3", "b4", "bla"],
            "P:N_2": ["a3", "b4", "bar"],
            "P:N_3": ["a3", "b4", "-l1", "-l2"],
            "P:N_4": ["a3", "b4", "samob"],
            "P:N_5": ["bla2", "bla"],
            "P:N_6": ["bla2", "bar"],
            "P:N_7": ["bla2", "-l1", "-l2"],
            "P:N_8": ["bla2", "samob"],
            "P:N_9": ["a", "a2", "bla"],
            "P:N:10": ["a", "a2", "bar"],
            "P:N_11": ["a", "a2", "-l1", "-l2"],
            "P:N_12": ["a", "a2", "samob"],
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
        actual = sanitize_flattened(name = "N", package = "P", input_flattened = input),
        msg = "Flattening select dicts failed",
    )

    return unittest.end(env)

sanitize_flattened_order_duplicates_test = unittest.make(_sanitize_order_duplicates_impl)

def _flatten_test_suite_impl(name, visibility):
    unittest.suite(
        name,
        partial.make(sanitize_flattened_order_test, tags = [TAG_STARLARK]),
        partial.make(sanitize_flattened_order_duplicates_test, tags = [TAG_STARLARK]),
    )

sanitize_test_suite = macro(
    implementation = _flatten_test_suite_impl,
)
