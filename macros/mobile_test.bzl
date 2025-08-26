load("//macros:ios_mobile_test.bzl", "ios_mobile_test")
load("//macros:android_mobile_test.bzl", "android_mobile_test")
load("//macros:wasm_test.bzl", "wasm_test")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load("//macros/flags:flags.bzl", "resolved_flags_select_dicts")
load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_ADVANCED",
    "TAG_WASM_ADVANCED_THREADS",
    "TAG_HOST",
    "TAG_IOS",
    "TAG_ANDROID",
)

def _mobile_test_impl(name, visibility, args, data, host_only, **kwargs):
    deps = kwargs.pop("deps") or select({
        Label("//conditions:default"): [],
    })
    srcs = kwargs.pop("srcs") or select({
        Label("//conditions:default"): [],
    })
    tags = kwargs.pop("tags") or []
    deps = deps + select({
        Label("//conditions:default"): [
            Label("//test-support/paths:test-paths"),
            Label("@googletest//:gtest_main"),
        ]
    })
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
    cc_test(
        name = name,
        srcs = srcs,
        visibility = visibility,
        linkopts = default_linkopts + linkopts,
        copts = default_copts + copts,
        cxxopts = default_cxxopts + cxxopts,
        conlyopts = default_conlyopts + conlyopts,
        deps = deps,
        tags = tags + [TAG_HOST],
        args = args,
        data = data,
        defines = defines,
        local_defines = local_defines,
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
            deps = deps,
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
        )
        android_mobile_test(
            name = name + "-android",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps,
            tags = tags,
            args = args,
            data = data,
            defines = defines,
            local_defines = local_defines,
        )
        wasm_test(
            name = name + "-wasm-basic",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps,
            threads = False,
            simd = False,
            args = args,
            tags = tags + [TAG_WASM_BASIC],
            data = data,
            defines = defines,
            local_defines = local_defines,
        )
        wasm_test(
            name = name + "-wasm-advanced",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps,
            threads = False,
            simd = True,
            args = args,
            tags = tags + [TAG_WASM_ADVANCED],
            data = data,
            defines = defines,
            local_defines = local_defines,
        )
        wasm_test(
            name = name + "-wasm-advanced-threads",
            visibility = visibility,
            srcs = srcs,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts,
            deps = deps,
            threads = True,
            simd = True,
            args = args,
            tags = tags + [TAG_WASM_ADVANCED_THREADS],
            data = data,
            defines = defines,
            local_defines = local_defines,
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
    }
)

def apply_to_all_generated_tests(test_name, func):
    func(test_name, [TAG_HOST])
    func(test_name + "-ios", [TAG_IOS, "exclusive"])
    func(test_name + "-android", [TAG_ANDROID, "exclusive"])
    func(test_name + "-wasm-basic", [TAG_WASM_BASIC])
    func(test_name + "-wasm-advanced", [TAG_WASM_ADVANCED])
    func(test_name + "-wasm-advanced-threads", [TAG_WASM_ADVANCED_THREADS])
