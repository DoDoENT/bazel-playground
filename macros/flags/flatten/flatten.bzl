load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:partial.bzl", "partial")

load("//macros:constants.bzl", "TAG_HOST")

# NOTE: starlark doesn't support recursive functions (https://bazel.build/rules/language),
#       so we need to  manually unroll the recursion up to the desired depth (3 levels in this case).
def _flatten_select_dicts_final(input_dict):
    config_setting_groups = dict()
    flat_select_dict = dict()

    for (key, value) in input_dict.items():
        if type(value) == type({}):
            fail("Flattening select dicts with more than 5 levels of nesting is not supported. Please flatten your select dicts to a maximum of 3 levels.")
        else: # no flattening needed
            flat_select_dict[key] = value

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict
    )

def _flatten_select_dicts_4(input_dict):
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = "L2_"
    counter = 0

    for (key, value) in input_dict.items():
        if type(value) == type({}):
            flattened_value = _flatten_select_dicts_final(input_dict = value)
            for (sub_key, sub_value) in flattened_value.flat_select_dict.items():
                counter = counter + 1
                config_group_name = config_group_name_prefix + str(counter)

                config_setting_groups[config_group_name] = [key] + flattened_value.config_setting_groups.get(sub_key, default = [sub_key])
                flat_select_dict[config_group_name] = sub_value
        else: # no flattening needed
            flat_select_dict[key] = value

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict
    )

def _flatten_select_dicts_3(input_dict):
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = "L2_"
    counter = 0

    for (key, value) in input_dict.items():
        if type(value) == type({}):
            flattened_value = _flatten_select_dicts_4(input_dict = value)
            for (sub_key, sub_value) in flattened_value.flat_select_dict.items():
                counter = counter + 1
                config_group_name = config_group_name_prefix + str(counter)

                config_setting_groups[config_group_name] = [key] + flattened_value.config_setting_groups.get(sub_key, default = [sub_key])
                flat_select_dict[config_group_name] = sub_value
        else: # no flattening needed
            flat_select_dict[key] = value

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict
    )

def _flatten_select_dicts_2(input_dict):
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = "L2_"
    counter = 0

    for (key, value) in input_dict.items():
        if type(value) == type({}):
            flattened_value = _flatten_select_dicts_3(input_dict = value)
            for (sub_key, sub_value) in flattened_value.flat_select_dict.items():
                counter = counter + 1
                config_group_name = config_group_name_prefix + str(counter)

                config_setting_groups[config_group_name] = [key] + flattened_value.config_setting_groups.get(sub_key, default = [sub_key])
                flat_select_dict[config_group_name] = sub_value
        else: # no flattening needed
            flat_select_dict[key] = value

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict
    )

def flatten_select_dicts(name, package, input_dict):
    """Flatten the nested select dicts into a single flat
       select dict that can be used with regular select()
       function.
       The output is a struct with fields:
            config_setting_groups: a dictionary of config groups.
                The key in this dictionary represents a config group name,
                derived from `name` and `package` parameters. This name is
                used in the resolved select dict to refer to conditions group.
                The value in this dictionary is an array of conditions that need
                to be given to `match_all` property of skylib's
                selects.config_setting_group.
                You need to create those groups in a `BUILD` file associated with
                provided `package`.
            flat_select_dict: a flattened select dict
                A flattened select dict usable with the `select` function.
                The keys in the dict refer to either original labels, in
                case when no flattening was needed, or to resolved merged
                config groups that need to be created in a `BUILD` file associated
                with provided `package`.
    """
    config_setting_groups = dict()
    flat_select_dict = dict()

    config_group_name_prefix = package + ":" + name + "_"
    counter = 0

    for (key, value) in input_dict.items():
        if type(value) == type({}):
            flattened_value = _flatten_select_dicts_2(input_dict = value)
            for (sub_key, sub_value) in flattened_value.flat_select_dict.items():
                counter = counter + 1
                config_group_name = config_group_name_prefix + str(counter)

                config_setting_groups[config_group_name] = [key] + flattened_value.config_setting_groups.get(sub_key, default = [sub_key])
                flat_select_dict[config_group_name] = sub_value
        else: # no flattening needed
            flat_select_dict[key] = value

    return struct(
        config_setting_groups = config_setting_groups,
        flat_select_dict = flat_select_dict
    )

def _unit_test_impl(ctx):
    env = unittest.begin(ctx)

    input_dict = {
        "condition1": {
            "A": ["-bla", "-bla2"],
            "B": {
                "C": ["-l1", "-l2"],
                "D": {
                    "E": ["bla"],
                    "F": ["bar"],
                },
            },
        },
        "condition2": ["default"],
    }

    expected = struct(
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

    asserts.equals(
        env = env,
        expected = expected,
        actual = flatten_select_dicts(name = "N", package = "P", input_dict = input_dict),
        msg = "Flattening select dicts failed",
    )

    return unittest.end(env)

flatten_select_dicts_test = unittest.make(_unit_test_impl)

def _flatten_test_suite_impl(name, visibility):
    unittest.suite(
        name,
        partial.make(flatten_select_dicts_test, tags = [TAG_HOST])
    )
    
flatten_test_suite = macro(
    implementation = _flatten_test_suite_impl,
)
