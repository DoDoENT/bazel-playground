def _eject_binary_impl(ctx):
    all_paths = []
    all_depsets = []
    for dep in ctx.attr.deps:
        all_depsets.append(dep.files)
        for file in dep.files.to_list():
            all_paths.append('"' + file.short_path + '"')

    ejector = ctx.actions.declare_file(ctx.label.name + "_eject.sh")
    ctx.actions.expand_template(
        output = ejector,
        template = ctx.file._eject_script_template,
        substitutions = {
            "%(FILES_TO_EJECT)a": " ".join(all_paths),
            "%(STRIP_PREFIX)s": ctx.attr.strip_prefix,
            "%(OUTPUT_DIR)s": ctx.attr.output_dir,
        },
    )

    return DefaultInfo(
        executable = ejector,
        runfiles = ctx.runfiles(transitive_files = depset(transitive = all_depsets)),
    )


eject_binary = rule(
    implementation = _eject_binary_impl,
    attrs = {
        "deps": attr.label_list(
            allow_files = True,
            doc = "Dependencies whose outputs will be ejected.",
        ),
        "strip_prefix": attr.string(
            default = "",
            doc = "A prefix to strip from the paths of the files to be ejected. This is a relative path from the workspace root.",
        ),
        "output_dir": attr.string(
            mandatory = True,
            doc = "The directory to which the outputs will be ejected. This is a relative path from the workspace root.",
        ),
        "_eject_script_template": attr.label(
            default = ":eject_binary.sh.tpl",
            allow_single_file = True,
        ),

    },
    executable = True,
    doc = "A runnable rule that copies the outputs of its dependencies to the given destination directory outside of the bazel sandbox.",
)
