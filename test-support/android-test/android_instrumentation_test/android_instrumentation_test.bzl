""" Android instrumentation test rule. """

load("@rules_android//providers:providers.bzl", "ApkInfo", "AndroidInstrumentationInfo")

def _android_instrumentation_test_impl(ctx):
    """Implementation of the android_instrumentation_test rule."""
    instrumentation_app_info = ctx.attr.test_app[AndroidInstrumentationInfo]
    if not instrumentation_app_info:
        fail("The 'test_app' attribute must provide an AndroidInstrumentationInfo provider.")
    instrumentation_apk = ctx.attr.test_app[ApkInfo]
    if not instrumentation_apk:
        fail("The 'test_app' attribute must provide an ApkInfo provider.")

    test_app = instrumentation_app_info.target

    instrumentation_script = ctx.actions.declare_file("android_instrumentation_test.sh")
    ctx.actions.expand_template(
        output = instrumentation_script,
        template = ctx.file._instrumentation_test_template,
        substitutions = {
            "%(test_host_apk)s": test_app.signed_apk.short_path,
            "%(instrumentation_apk)s": instrumentation_apk.signed_apk.short_path,
        },
    )
    return [
        DefaultInfo(
            executable = instrumentation_script,
        ),
    ]



android_instrumentation_test = rule(
    implementation = _android_instrumentation_test_impl,
    attrs = {
        "test_app": attr.label(
            mandatory = True,
            doc = "The Android instrumentation application to run.",
            providers = [ApkInfo, AndroidInstrumentationInfo],
        ),
        "_instrumentation_test_template": attr.label(
            default = "android_instrumentation_test.template.sh",
            allow_single_file = True,
        ),
    },
    test = True,
    doc = "Runs Android instrumentation tests using the specified test application.",
)
