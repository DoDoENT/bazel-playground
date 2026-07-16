"""Downloads Headless Chrome archives and selects one for the execution platform."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":chrome_versions.bzl", "CHROME_VERSIONS")

_CHROME_PLATFORMS = {
    "linux64": {
        "constraints": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "archive_dir": "linux64",
    },
    "mac_arm64": {
        "constraints": [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        "archive_dir": "mac-arm64",
    },
    "mac_x64": {
        "constraints": [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        "archive_dir": "mac-x64",
    },
    "win64": {
        "constraints": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        "archive_dir": "win64",
    },
    "win32": {
        "constraints": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_32",
        ],
        "archive_dir": "win32",
    },
}

def _chrome_selector_repo_impl(rctx):
    config_settings = []
    chrome_select = []
    chrome_data_select = []

    for platform_name, archive_repo in rctx.attr.archive_repositories.items():
        platform_info = _CHROME_PLATFORMS[platform_name]
        config_settings.append("""
config_setting(
    name = "{platform_name}",
    constraint_values = {constraints},
)
""".format(
            platform_name = platform_name,
            constraints = repr(platform_info["constraints"]),
        ))
        chrome_select.append('        ":{platform_name}": "@{archive_repo}//:chrome",'.format(
            platform_name = platform_name,
            archive_repo = archive_repo,
        ))
        chrome_data_select.append('        ":{platform_name}": "@{archive_repo}//:chrome-data",'.format(
            platform_name = platform_name,
            archive_repo = archive_repo,
        ))

    rctx.file("BUILD.bazel", """
{config_settings}

alias(
    name = "chrome",
    actual = select(
        {{
{chrome_select}
        }},
        no_match_error = "Headless Chrome is unavailable for the selected execution platform",
    ),
    visibility = ["//visibility:public"],
)

alias(
    name = "chrome-data",
    actual = select(
        {{
{chrome_data_select}
        }},
        no_match_error = "Headless Chrome is unavailable for the selected execution platform",
    ),
    visibility = ["//visibility:public"],
)
""".format(
        config_settings = "\n".join(config_settings),
        chrome_select = "\n".join(chrome_select),
        chrome_data_select = "\n".join(chrome_data_select),
    ))

_chrome_selector_repo = repository_rule(
    implementation = _chrome_selector_repo_impl,
    attrs = {
        "archive_repositories": attr.string_dict(mandatory = True),
    },
)

def _chrome_extension_impl(module_ctx):
    version_info = None
    chrome_repo_name = None

    for mod in module_ctx.modules:
        for install_chrome_tag in mod.tags.install_chrome:
            if version_info == None:
                version_info = CHROME_VERSIONS[install_chrome_tag.version]
                chrome_repo_name = install_chrome_tag.name
            else:
                fail("Only one install_chrome tag is allowed in the entire workspace.")

    if version_info == None:
        return None

    chrome_version = version_info["version"]
    archive_repositories = {}

    # Repository resolution happens on the Bazel host, before an execution
    # platform is selected. Declare every archive here and defer the choice to
    # a select() in _chrome_selector_repo, which is consumed with cfg = "exec".
    for platform_name, platform_info in _CHROME_PLATFORMS.items():
        archive_dir = platform_info["archive_dir"]
        integrity_key = "{}-integrity".format(archive_dir)
        if integrity_key not in version_info:
            continue

        archive_repo_name = "{}_{}".format(chrome_repo_name, platform_name)
        archive_repositories[platform_name] = archive_repo_name

        http_archive(
            name = archive_repo_name,
            url = "https://storage.googleapis.com/chrome-for-testing-public/{version}/{archive_dir}/chrome-headless-shell-{archive_dir}.zip".format(
                version = chrome_version,
                archive_dir = archive_dir,
            ),
            strip_prefix = "chrome-headless-shell-{}".format(archive_dir),
            build_file = "chrome.BUILD.bazel",
            integrity = version_info[integrity_key],
        )

    _chrome_selector_repo(
        name = chrome_repo_name,
        archive_repositories = archive_repositories,
    )

    return module_ctx.extension_metadata(
        reproducible = True,
    )

chrome_extension = module_extension(
    implementation = _chrome_extension_impl,
    tag_classes = {
        "install_chrome": tag_class(
            attrs = {
                "version": attr.string(
                    mandatory = True,
                    doc = "Chrome version to download.",
                    values = CHROME_VERSIONS.keys(),
                    default = CHROME_VERSIONS.keys()[0],
                ),
                "name": attr.string(
                    default = "chrome",
                    doc = "Name of the repository containing downloaded Chrome.",
                ),
            },
        ),
    },
)
