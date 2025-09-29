def _posluznik_test_impl(ctx):
    """Implementation for the posluznik_test rule."""
    wasm_mobile_binary = ctx.files.wasm_mobile_binary[0]

    posluznik_files = ctx.attr._posluznik[DefaultInfo].files
    chrome = ctx.attr._chrome[DefaultInfo].files
    chrome_files = ctx.attr._chrome_data[DefaultInfo].files
    wasm_mobile_files = ctx.attr.wasm_mobile_binary[DefaultInfo].files

    runfiles_needed = [
        posluznik_files,
        wasm_mobile_files,
        chrome,
        chrome_files,
    ]

    substitutions = {
        "%(posluznik)s": ctx.executable._posluznik.short_path,
        "%(wasm_mobile_binary)s": wasm_mobile_binary.short_path,
        "%(args)s": " ".join(ctx.attr.args),
        "%(chrome)s": ctx.executable._chrome.short_path,
    }

    if ctx.attr.validate_binary != "off":
        wasm_walidate = ctx.attr._wasm_validate[DefaultInfo].files
        runfiles_needed.append(wasm_walidate)

        if ctx.attr.validate_binary == "basic":
            wasm_validate_flags = "--disable-simd"
        elif ctx.attr.validate_binary == "simd":
            wasm_validate_flags = ""
        elif ctx.attr.validate_binary == "simd+threads":
            wasm_validate_flags = "--enable-threads"

        substitutions["%(wasm_validate_enabled)b"] = "true"
        substitutions["%(wasm_validate_flags)s"] = wasm_validate_flags
        substitutions["%(wasm_validate)s"] = ctx.executable._wasm_validate.short_path
    else:
        substitutions["%(wasm_validate_enabled)b"] = "false"

    test_script = ctx.actions.declare_file(ctx.label.name + "_posluznik_test.sh")
    ctx.actions.expand_template(
        output = test_script,
        template = ctx.file._posluznik_test_template,
        substitutions = substitutions,
    )

    return [
        DefaultInfo(
            executable = test_script,
            runfiles = ctx.runfiles(
                transitive_files = depset(
                    transitive = runfiles_needed,
                )
            ),
        ),
    ]


posluznik_test = rule(
    implementation = _posluznik_test_impl,
    attrs = {
        "wasm_mobile_binary": attr.label(
            mandatory = True,
            doc = "The WebAssembly mobile binary to test.",
        ),
        "validate_binary": attr.string(
            default = "off",
            values = ["off", "basic", "simd", "simd+threads"],
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
        "_chrome": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@chrome//:chrome",
            executable = True,
        ),
        "_chrome_data": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@chrome//:chrome-data",
        ),
        "_wasm_validate": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@wabt//src/tools:wasm-validate",
            executable = True,
        ),
    },
    test = True,
)
