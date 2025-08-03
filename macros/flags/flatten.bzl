load("@bazel_skylib//lib:selects.bzl", "selects")

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

def _create_config_setting_groups(name, visibility, config_setting_groups):
    """Create config setting groups in the `BUILD` file associated with
       provided `package` parameter.
       The `input_dict` is a dictionary of config groups that need to be created.
       The keys in the dict refer to either original labels, in
       case when no flattening was needed, or to resolved merged
       config groups that need to be created in a `BUILD` file associated
       with provided `package`.
    """
    for (group_name, conditions) in config_setting_groups.items():
        selects.config_setting_group(
            name = group_name,
            match_all = conditions,
        )

create_config_setting_groups = macro(
    implementation = _create_config_setting_groups,
    attrs = {
        "config_setting_groups": attr.string_list_dict(
            mandatory = True,
        ),
    },
)
