load(
    ":constants.bzl",
    "TAG_WASM_BASIC",
    "TAG_WASM_ADVANCED",
    "TAG_WASM_ADVANCED_THREADS",
    "TAG_IOS",
    "TAG_ANDROID",
    "TAG_HOST",
)

def _define_test_suites_impl(name, visibility):
    native.test_suite(
        name = TAG_HOST,
        tags = [TAG_HOST],
    )

    native.test_suite(
        name = TAG_ANDROID,
        tags = [TAG_ANDROID],
    )

    native.test_suite(
        name = TAG_IOS,
        tags = [TAG_IOS],
    )

    native.test_suite(
        name = TAG_WASM_BASIC,
        tags = [TAG_WASM_BASIC],
    )

    native.test_suite(
        name = TAG_WASM_ADVANCED,
        tags = [TAG_WASM_ADVANCED],
    )

    native.test_suite(
        name = TAG_WASM_ADVANCED_THREADS,
        tags = [TAG_WASM_ADVANCED_THREADS],
    )

define_test_suites = macro(
    implementation = _define_test_suites_impl,
)

def _define_subpackage_test_suites_impl(name, visibility, subpackages):
    pkg_name = native.package_name()
    prefix = "//"
    if len(pkg_name) > 0:
        prefix += pkg_name + "/"

    collect_subpackages = lambda name: [
        prefix + subpackage + ":" + name for subpackage in subpackages
    ]

    native.test_suite(
        name = TAG_HOST,
        tests = collect_subpackages(TAG_HOST),
    )

    native.test_suite(
        name = TAG_ANDROID,
        tests = collect_subpackages(TAG_ANDROID),
    )

    native.test_suite(
        name = TAG_IOS,
        tests = collect_subpackages(TAG_IOS),
    )

    native.test_suite(
        name = TAG_WASM_BASIC,
        tests = collect_subpackages(TAG_WASM_BASIC),
    )

    native.test_suite(
        name = TAG_WASM_ADVANCED,
        tests = collect_subpackages(TAG_WASM_ADVANCED),
    )

    native.test_suite(
        name = TAG_WASM_ADVANCED_THREADS,
        tests = collect_subpackages(TAG_WASM_ADVANCED_THREADS),
    )

    native.test_suite(
        name = "wasm-all",
        tests =[
            ":" + TAG_WASM_BASIC,
            ":" + TAG_WASM_ADVANCED,
            ":" + TAG_WASM_ADVANCED_THREADS,
        ],
    )



define_subpackage_test_suites = macro(
    implementation = _define_subpackage_test_suites_impl,
    attrs = {
        "subpackages": attr.string_list(
            doc = "List of subpackages to define test suites for.",
            mandatory = True,
            configurable = False,
        ),
    },
)

