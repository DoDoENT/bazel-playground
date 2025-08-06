load("@bazel_skylib//lib:selects.bzl", "selects")

def create_config_setting_groups(config_setting_groups):
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
            name = group_name.name,
            match_all = conditions,
        )
