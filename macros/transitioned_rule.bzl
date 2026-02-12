load("@rules_android//providers:providers.bzl", "ApkInfo")
load("@rules_apple//apple:providers.bzl", "AppleBundleInfo", "IosApplicationBundleInfo")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")

def create_transitioned_rule(transition):
    def _impl(ctx):
        actual_binary = ctx.attr.actual_binary[0]
        providers = []

        # Handle DefaultInfo without claiming 'ownership' of the executable
        # This allows the .ipa or .apk to be collected as a data file
        providers.append(DefaultInfo(
            files = actual_binary[DefaultInfo].files,
            runfiles = actual_binary[DefaultInfo].default_runfiles,
        ))

        if IosApplicationBundleInfo in actual_binary:
            providers.append(actual_binary[IosApplicationBundleInfo])

        if AppleBundleInfo in actual_binary:
            providers.append(actual_binary[AppleBundleInfo])

        if ApkInfo in actual_binary:
            providers.append(actual_binary[ApkInfo])

        if CcInfo in actual_binary:
            providers.append(actual_binary[CcInfo])

        if OutputGroupInfo in actual_binary:
            providers.append(actual_binary[OutputGroupInfo])

        return providers

    return rule(
        implementation = _impl,
        attrs = {
            "actual_binary": attr.label(cfg = transition),
        },
    )

