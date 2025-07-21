"""
An iOS test runner rule that uses xctestrun files to run unit test bundles on
devices.
"""

load(
    "//apple:providers.bzl",
    "AppleDeviceTestRunnerInfo",
    "apple_provider",
)

AppleKeyChainInfo = provider(
    doc = """
Provider for a keychain that needs to be unlocked when running test on a real device.
""",
    fields = {
        "keychain_path": "Path to the keychain file.",
        "keychain_password": "Password for the keychain.",
    },
)

def _get_template_substitutions(
        *,
        device_name,
        xcodebuild_args,
        destination_timeout,
    substitutions = {
        "device_name": device_name,
        "xcodebuild_args": xcodebuild_args,
        "destination_timeout": destination_timeout,
    }

    return {"%({})s".format(key): value for key, value in substitutions.items()}

def _get_execution_environment(ctx):
    xcode_version = str(ctx.attr._xcode_config[apple_common.XcodeVersionConfig].xcode_version())
    if not xcode_version:
        fail("error: No xcode_version in _xcode_config")

    return {"XCODE_VERSION_OVERRIDE": xcode_version}

def _ios_xctestrun_runner_impl(ctx):
    device_name = ctx.attr.device_name

    ctx.actions.expand_template(
        template = ctx.file._test_template,
        output = ctx.outputs.test_runner_template,
        substitutions = _get_template_substitutions(
            device_name = device_name,
            xcodebuild_args = " ".join(ctx.attr.xcodebuild_args) if ctx.attr.xcodebuild_args else "",
            destination_timeout = "" if ctx.attr.destination_timeout == 0 else str(ctx.attr.destination_timeout),
        ),
    )

    return [
        apple_provider.make_apple_test_runner_info(
            execution_environment = _get_execution_environment(ctx),
            execution_requirements = {"requires-darwin": ""},
            test_runner_template = ctx.outputs.test_runner_template,
        ),
    ]

ios_xctestrun_runner = rule(
    _ios_xctestrun_runner_impl,
    attrs = {
        "xcode_project": attr.label(
            doc = """
Xcode project target created with xcodeproj rule and configured with at least one test scheme.
""",
            mandatory = True,
            providers = ["AppleXcodeProjectInfo"],
        ),
        "device_name": attr.string(
            doc = """
Device on which test will be executed. It will be given as '-destinaion 'platform=iOS,name=<device_name>' to `xcodebuild`
invocation. If not set, $DEVICE_NAME environment variable will be used which should be provided via --test_env flag (e.g. in CI systems)
""",
        ),
        "device_id": attr.string(
            doc = """
Device on which test will be executed. It will be given as '-destinaion 'platform=iOS,id=<device_name>' to `xcodebuild`
invocation. If not set, $DEVICE_ID environment variable will be used which should be provided via --test_env flag (e.g. in CI systems)
""",
        ),
        "keychain": attr.label(
            doc = """
Label providing a keychain to use for the test run. If not specified, the default keychain will be used which is expected
to be unlocked and available for use.
""",
            provider = "AppleKeychainInfo",
        )
        "xcodebuild_args": attr.string_list(
            doc = """
Arguments to pass to `xcodebuild` when running the test.
""",
        ),
        "destination_timeout": attr.int(
            doc = "Use the specified timeout when searching for a destination device. The default is 30 seconds.",
        ),
        "_test_template": attr.label(
            default = Label(
                "//apple/testing/default_runner:ios_xctest_device_runner.template.sh",
            ),
            allow_single_file = True,
        ),
        "_xcode_config": attr.label(
            default = configuration_field(
                name = "xcode_config_label",
                fragment = "apple",
            ),
        ),
    },
    outputs = {
        "test_runner_template": "%{name}.sh",
    },
    fragments = ["apple"],
)
