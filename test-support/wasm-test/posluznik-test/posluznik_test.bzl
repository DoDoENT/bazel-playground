def _posluznik_test_impl(ctx):
    """Implementation for the posluznik_test rule."""
    wasm_mobile_binary = ctx.files.wasm_mobile_binary[0]

    posluznik_files = ctx.attr._posluznik[DefaultInfo].files
    wasm_mobile_files = ctx.attr.wasm_mobile_binary[DefaultInfo].files

    substitutions = {
        "%(posluznik)s": ctx.executable._posluznik.short_path,
        "%(wasm_mobile_binary)s": wasm_mobile_binary.short_path,
        "%(args)s": " ".join(ctx.attr.args),
    }

    test_script = ctx.actions.declare_file(ctx.label.name + "_posluznik_test.sh")
    ctx.actions.expand_template(
        output = test_script,
        template = ctx.file._posluznik_test_template,
        substitutions = substitutions,
    )

    return [
        DefaultInfo(
            executable = test_script,
            runfiles = ctx.runfiles(transitive_files = depset(transitive = [posluznik_files, wasm_mobile_files])),
        ),
    ]


posluznik_test = rule(
    implementation = _posluznik_test_impl,
    attrs = {
        "wasm_mobile_binary": attr.label(
            mandatory = True,
            doc = "The WebAssembly mobile binary to test.",
        ),
        "_posluznik_test_template": attr.label(
            default = "posluznik_test.template.sh",
            allow_single_file = True,
        ),
        "_posluznik": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@posluznik//:posluznik",
            executable = True,
        ),
    },
    test = True,
)
