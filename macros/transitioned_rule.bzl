load("@rules_android//providers:providers.bzl", "ApkInfo")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load(
    "@rules_apple//apple:providers.bzl",
    "AppleBundleInfo",
    "IosApplicationBundleInfo",
    "AppleBinaryInfo",
)
load(
    "@rules_swift//swift:providers.bzl",
    "SwiftBinaryInfo",
    "SwiftInfo",
    "SwiftOverlayInfo",
)

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

        providers_to_pass_through = [
            SwiftBinaryInfo,
            SwiftInfo,
            SwiftOverlayInfo,
            IosApplicationBundleInfo,
            AppleBundleInfo,
            AppleBinaryInfo,
            ApkInfo,
            CcInfo,
            OutputGroupInfo,
        ]

        for provider in providers_to_pass_through:
            if provider in actual_binary:
                providers.append(actual_binary[provider])

        return providers

    return rule(
        implementation = _impl,
        attrs = {
            "actual_binary": attr.label(cfg = transition),
        },
    )

