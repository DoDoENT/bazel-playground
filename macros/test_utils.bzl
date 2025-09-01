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

def _collect_deps_impl(ctx):
    collected_files = []
    for dep in ctx.attr.deps:
        for file in dep.files.to_list():
            collected_files.append(file)

    ctx.actions.do_nothing(
        inputs = collected_files,
        mnemonic = "CollectDependencies",
    )
    return [DefaultInfo(files = depset(collected_files))]

collect_dependencies = rule(
    implementation = _collect_deps_impl,
    attrs = {
        "deps": attr.label_list(allow_files = True),
    }
)
