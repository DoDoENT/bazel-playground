def sanitize_flattened(name, package, input_flattened):
    """Sanitizes the flattened structure by reordering entries in a way
       that those with more conditions are before those with less conditions.
       Thus, more specialized conditions are always preferred to more general
       ones. Relative order of entries with same number of conditions is
       left unchanged.
       Additionally, duplicate propositions in config_setting_groups are removed
       The input and output of the function is the structure described in
       `flatten_select_dicts` function.
    """
    pass
