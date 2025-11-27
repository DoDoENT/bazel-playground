load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")
load("//macros:android_mobile_test.bzl", "android_mobile_test")
load("//macros:ios_mobile_test.bzl", "ios_mobile_test")
load("//macros:mobile_library.bzl", "mobile_library")
load("//macros:wasm_test.bzl", "wasm_test")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_ADVANCED",
    "TAG_WASM_ADVANCED_THREADS",
    "TAG_HOST",
    "TAG_IOS",
    "TAG_ANDROID",
)

def _mobile_test_impl(name, visibility, args, data, host_only, android_deploy_resources, **kwargs):

    mobile_library(
        name = name + "-paths",
        srcs = [
            Label("//test-support/paths:test-paths-impl"),
        ],
        local_defines = [
            'PKG_NAME=\\"' + native.package_name() + '\\"',
        ],
        deps = [
            Label("//test-support/paths:test-paths"),
        ],
        testonly = True,
    )

    deps = kwargs.pop("deps") or select({
        Label("//conditions:default"): [],
    })
    srcs = kwargs.pop("srcs") or select({
        Label("//conditions:default"): [],
    })
    tags = kwargs.pop("tags") or []
    default_conlyopts = select(resolved_flags_select_dicts["conlyopts"].flat_select_dict)
    default_copts = select(resolved_flags_select_dicts["copts"].flat_select_dict)
    default_cxxopts = select(resolved_flags_select_dicts["cxxopts"].flat_select_dict)
    default_linkopts = select(resolved_flags_select_dicts["linkopts"].flat_select_dict)
    conlyopts = kwargs.pop("conlyopts") or select({
        Label("//conditions:default"): []
    })
    copts = kwargs.pop("copts") or select({
        Label("//conditions:default"): [],
    })
    cxxopts = kwargs.pop("cxxopts") or select({
        Label("//conditions:default"): [],
    })
    linkopts = kwargs.pop("linkopts") or select({
        Label("//conditions:default"): [],
    })
    defines = kwargs.pop("defines") or select({
        Label("//conditions:default"): [],
    })
    local_defines = kwargs.pop("local_defines") or select({
        Label("//conditions:default"): [],
    })
    linkstatic = kwargs.pop("linkstatic")
    if linkstatic == None:
        linkstatic = True  # Default to static linking if not specified
    test_size = kwargs.pop("size")
    test_timeout = kwargs.pop("timeout")

    cc_test(
        name = name,
        srcs = srcs,
        visibility = visibility,
        linkopts = default_linkopts + linkopts,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        conlyopts = default_conlyopts + conlyopts,
        deps = deps + [
            native.package_relative_label(":" + name + "-paths"),
            Label("@googletest//:gtest_main"),
        ],
        tags = tags + [TAG_HOST],
        args = args,
        data = data,
        defines = defines,
        local_defines = local_defines,
        linkstatic = linkstatic,
        size = test_size,
        timeout = test_timeout,
        **kwargs,
    )
    if not host_only:
        # Note: iOS, Android, and Wasm will internally add default copts, cxxopts, and linkopts
        ios_mobile_test(
            name = name + "-ios",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
            size = test_size,
            timeout = test_timeout,
        )
        android_mobile_test(
            name = name + "-android",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
            deploy_resources = android_deploy_resources,
            size = test_size,
            timeout = test_timeout,
        )
        wasm_test(
            name = name + "-wasm-basic",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            threads = False,
            simd = False,
            args = args,
            tags = tags + [TAG_WASM_BASIC],
            data = data,
            defines = defines,
            local_defines = local_defines,
            size = test_size,
            timeout = test_timeout,
        )
        wasm_test(
            name = name + "-wasm-advanced",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            threads = False,
            simd = True,
            args = args,
            tags = tags + [TAG_WASM_ADVANCED],
            data = data,
            defines = defines,
            local_defines = local_defines,
            size = test_size,
            timeout = test_timeout,
        )
        wasm_test(
            name = name + "-wasm-advanced-threads",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps + [
                native.package_relative_label(":" + name + "-paths"),
            ],
            threads = True,
            simd = True,
            args = args,
            tags = tags + [TAG_WASM_ADVANCED_THREADS],
            data = data,
            defines = defines,
            local_defines = local_defines,
            size = test_size,
            timeout = test_timeout,
        )


mobile_test = macro(
    implementation = _mobile_test_impl,
    inherit_attrs = native.cc_test,
    attrs = {
        "args": attr.string_list(
            default = [],
            doc = "Arguments for the mobile test.",
            configurable = False,
        ),
        "data": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Test data files",
            configurable = False,
        ),
        "host_only": attr.bool(
            default = False,
            doc = "If true, only define the host version of the test.",
            configurable = False,
        ),
        "android_deploy_resources": attr.bool(
            default = False,
            configurable = False,
            doc = "If true, on Android test data files will be deployed to the internal storage prior launching the C++ code",
        ),
    }
)

def create_transitioned_test_rule(transition):
    def _impl(ctx):
        # We need to copy the executable because starlark doesn't allow
        # providing an executable not created by the rule
        executable_src = ctx.executable.actual_test
        executable_dst = ctx.actions.declare_file(ctx.label.name)
        ctx.actions.run_shell(
            tools = [executable_src],
            outputs = [executable_dst],
            command = "cp %s %s" % (executable_src.path, executable_dst.path),
        )
        runfiles = ctx.attr.actual_test[DefaultInfo].default_runfiles
        return [DefaultInfo(runfiles = runfiles, executable = executable_dst)]

    return rule(
        cfg = transition,
        implementation = _impl,
        attrs = {
            "actual_test": attr.label(cfg = "target", executable = True),
        },
        test = True,
    )

def apply_to_all_generated_tests(test_names, func, *, host=True, ios=True, android=True, wasm_basic=True, wasm_advanced=True, wasm_advanced_threads=True, additional_tags=[]):
    for test_name in test_names:
        if host:
            func(test_name, [TAG_HOST] + additional_tags)
        if ios:
            func(test_name + "-ios", [TAG_IOS, "exclusive"] + additional_tags)
        if android:
            func(test_name + "-android", [TAG_ANDROID, "exclusive"] + additional_tags)
        if wasm_basic:
            func(test_name + "-wasm-basic", [TAG_WASM_BASIC] + additional_tags)
        if wasm_advanced:
            func(test_name + "-wasm-advanced", [TAG_WASM_ADVANCED] + additional_tags)
        if wasm_advanced_threads:
            func(test_name + "-wasm-advanced-threads", [TAG_WASM_ADVANCED_THREADS] + additional_tags)
