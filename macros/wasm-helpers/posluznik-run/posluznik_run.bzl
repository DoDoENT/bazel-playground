def _posluznik_run_impl(ctx):
    """Implementation for the posluznik_run rule."""
    wasm_mobile_binary = ctx.files.wasm_mobile_binary[0]

    posluznik_files = ctx.attr._posluznik[DefaultInfo].files
    wasm_mobile_files = ctx.attr.wasm_mobile_binary[DefaultInfo].files
    html_shell_files = ctx.attr.html_shell[DefaultInfo].files if ctx.attr.html_shell else depset()

    runfiles_needed = [
        posluznik_files,
        wasm_mobile_files,
        html_shell_files,
    ]

    substitutions = {
        "%(posluznik)s": ctx.executable._posluznik.short_path,
        "%(wasm_mobile_binary)s": wasm_mobile_binary.short_path,
        "%(args)s": " ".join(ctx.attr.args),
    }

    run_script = ctx.actions.declare_file(ctx.label.name + "_posluznik_run.sh")
    ctx.actions.expand_template(
        output = run_script,
        template = ctx.file._posluznik_run_template,
        substitutions = substitutions,
    )

    return [
        DefaultInfo(
            executable = run_script,
            runfiles = ctx.runfiles(
                transitive_files = depset(
                    transitive = runfiles_needed,
                )
            ),
        ),
    ]


posluznik_run = rule(
    implementation = _posluznik_run_impl,
    attrs = {
        "wasm_mobile_binary": attr.label(
            mandatory = True,
            doc = "The WebAssembly mobile binary to run.",
        ),
        "html_shell": attr.label(
            default = None,
            doc = "The HTML shell file for the WebAssembly mobile binary.",
        ),
        "_posluznik_run_template": attr.label(
            default = "posluznik_run.template.sh",
            allow_single_file = True,
        ),
        "_posluznik": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@posluznik//:posluznik",
            executable = True,
        ),
    },
    executable = True,
)
