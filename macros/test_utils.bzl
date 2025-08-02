def _prepare_assets_impl(ctx):
    output_dir = ctx.label.name
    outputs = []
    for dep in ctx.attr.data:
        for file in dep.files.to_list():
            output = ctx.actions.declare_file("%s/%s" % (output_dir, file.path))
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )
            outputs.append(output)
    return [DefaultInfo(files = depset(outputs))]

prepare_assets = rule(
    implementation = _prepare_assets_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
    }
)
