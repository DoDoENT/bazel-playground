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
    for dep in ctx.attr.deps_runfiles:
        for file in dep[DefaultInfo].default_runfiles.files.to_list():
            output = ctx.actions.declare_file("%s/%s" % (output_dir, file.short_path))
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )
            outputs.append(output)
    if len(outputs) == 0 and ctx.attr.ensure_non_empty:
        # Create an empty placeholder file to ensure the rule always has an output
        # (this is required for WASM builds that have no data depedendencies and no
        # deps that provide runfiles)
        output = ctx.actions.declare_file("%s/.empty" % output_dir)
        ctx.actions.write(
            output = output,
            content = "",
        )
        outputs.append(output)
    return DefaultInfo(files = depset(outputs))

prepare_assets = rule(
    implementation = _prepare_assets_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
        "deps_runfiles": attr.label_list(allow_files = True),
        "ensure_non_empty": attr.bool(
            default = False,
            doc = "If true, ensures that the output is non-empty by adding a placeholder file if necessary.",
        ),
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

def remove_cc_binary_specific_attrs(kwargs):
    # Remove cc_binary-specific attrs that don't make sense for android_binary
    remove_attrs = [
        "output_licenses",
        "reexport_deps",
        "nocopts",
        "malloc",
        "link_extra_lib",
        "stamp",
        "linkshared",
        "env",
        "distribs",
        "dynamic_deps",
    ]
    for attr in remove_attrs:
        kwargs.pop(attr)

