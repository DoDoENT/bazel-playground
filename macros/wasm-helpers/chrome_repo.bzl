load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

load(":chrome_versions.bzl", "CHROME_VERSIONS")

def _chrome_extension_impl(module_ctx):
    version_info = None

    for mod in module_ctx.modules:
        for install_chrome_tag in mod.tags.install_chrome:
            if version_info == None:
                version_info = CHROME_VERSIONS[install_chrome_tag.version]
                chrome_repo_name = install_chrome_tag.name
            else:
                fail("Only one install_chrome tag is allowed in the entire workspace.")

    chrome_version = version_info["version"]

    url = None
    prefix = None
    integrity = None
    if module_ctx.os.name == "linux":
        if module_ctx.os.arch == "amd64":
            url = "https://storage.googleapis.com/chrome-for-testing-public/{}/linux64/chrome-headless-shell-linux64.zip".format(chrome_version)
            prefix = "chrome-headless-shell-linux64"
            integrity = version_info["linux64-integrity"]
    elif module_ctx.os.name == "mac os x":
        if module_ctx.os.arch == "aarch64":
            url = "https://storage.googleapis.com/chrome-for-testing-public/{}/mac-arm64/chrome-headless-shell-mac-arm64.zip".format(chrome_version)
            prefix = "chrome-headless-shell-mac-arm64"
            integrity = version_info["mac-arm64-integrity"]
        elif module_ctx.os.arch == "x86_64":
            url = "https://storage.googleapis.com/chrome-for-testing-public/{}/mac-x64/chrome-headless-shell-mac-x64.zip".format(chrome_version)
            prefix = "chrome-headless-shell-mac-x64"
            integrity = version_info["mac-x64-integrity"]
    elif module_ctx.os.name == "windows":
        if module_ctx.os.arch == "amd64":
            url = "https://storage.googleapis.com/chrome-for-testing-public/{}/win64/chrome-headless-shell-win64.zip".format(chrome_version)
            prefix = "chrome-headless-shell-win64"
            integrity = version_info["win64-integrity"]
        elif module_ctx.os.arch == "x86":
            url = "https://storage.googleapis.com/chrome-for-testing-public/{}/win32/chrome-headless-shell-win32.zip".format(chrome_version)
            prefix = "chrome-headless-shell-win32"
            integrity = version_info["win32-integrity"]

    if url != None:
        module_ctx.report_progress("Downloading Headless Chrome version {} from {}".format(chrome_version, url))
        http_archive(
            name = chrome_repo_name,
            url = url,
            strip_prefix = prefix,
            build_file = "chrome.BUILD.bazel",
            integrity = integrity,
        )

        return module_ctx.extension_metadata(
            reproducible = True,
        )
    else:
        fail("No Chrome build available for OS {}, architecture {}".format(module_ctx.os.name, module_ctx.os.arch))


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
    os_dependent = True,
    arch_dependent = True,
)
