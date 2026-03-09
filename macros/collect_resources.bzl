def _collect_resources_impl(ctx):
    # Create a directory for collected resources
    output_dir = ctx.attr.resource_output_dir

    outputs = []

    # Collect resources from the specified files
    for resource in ctx.attr.resources:
        for file in resource.files.to_list():
            file_name = file.basename
            output = ctx.actions.declare_file("{}/{}".format(output_dir, file_name))
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )
            outputs.append(output)

    # Collect resources from dependencies' runfiles
    for dep in ctx.attr.deps_runfiles:
        for file in dep[DefaultInfo].default_runfiles.files.to_list():
            output = ctx.actions.declare_file("%s/%s" % (output_dir, file.basename))
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )
            outputs.append(output)

    return DefaultInfo(files = depset(outputs))


collect_resources = rule(
    implementation = _collect_resources_impl,
    attrs = {
        "resources": attr.label_list(
            allow_files = True,
            doc = "List of resource files to collect.",
        ),
        "deps_runfiles": attr.label_list(
            allow_files = True,
            doc = "List of dependencies whose runfiles should be collected as resources.",
        ),
        "resource_output_dir": attr.string(
            mandatory = True,
            doc = "Directory where collected resources will be outputted.",
        ),
    }
)
