""" Android instrumentation test rule. """

load("@rules_android//providers:providers.bzl", "ApkInfo", "AndroidInstrumentationInfo")

def _android_instrumentation_test_impl(ctx):
    """Implementation of the android_instrumentation_test rule."""

    instrumentation_app_info = None
    if AndroidInstrumentationInfo in ctx.attr.test_app:
        instrumentation_app_info = ctx.attr.test_app[AndroidInstrumentationInfo]

    instrumentation_apk = ctx.attr.test_app[ApkInfo]
    if not instrumentation_apk:
        fail("The 'test_app' attribute must provide an ApkInfo provider.")

    test_app = None
    if instrumentation_app_info:
        test_app = instrumentation_app_info.target

    adb = ctx.executable._adb
    aapt2 = ctx.files._aapt2[0]

    runfiles = [
        adb,
        aapt2,
        instrumentation_apk.signed_apk,
    ]
    if test_app:
        runfiles.append(test_app.signed_apk)

    substitutions = {
        "%(instrumentation_apk)s": instrumentation_apk.signed_apk.short_path,
        "%(adb)s": adb.short_path,
        "%(aapt2)s": aapt2.short_path,
    } 

    if test_app:
        substitutions["%(test_host_apk)s"] = test_app.signed_apk.short_path

    instrumentation_script = ctx.actions.declare_file(ctx.label.name + "_android_instrumentation_test.sh")
    ctx.actions.expand_template(
        output = instrumentation_script,
        template = ctx.file._instrumentation_test_template,
        substitutions = substitutions,
    )
    return [
        DefaultInfo(
            executable = instrumentation_script,
            runfiles = ctx.runfiles(runfiles, transitive_files = ctx.attr._aapt2.default_runfiles.files),
        ),
    ]


android_instrumentation_test = rule(
    implementation = _android_instrumentation_test_impl,
    attrs = {
        "test_app": attr.label(
            mandatory = True,
            doc = "The Android instrumentation application to run.",
            providers = [ApkInfo],
        ),
        "_instrumentation_test_template": attr.label(
            default = "android_instrumentation_test.template.sh",
            allow_single_file = True,
        ),
        "_adb": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@androidsdk//:platform-tools/adb",
            executable = True,
        ),
        "_aapt2": attr.label(
            allow_files = True,
            cfg = "exec",
            default = "@androidsdk//:aapt2",
        ),
    },
    toolchains = ["@bazel_tools//tools/sh:toolchain_type"],
    test = True,
    doc = "Runs Android instrumentation tests using the specified test application.",
)
