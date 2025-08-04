load("//macros:constants.bzl", "TAG_STARLARK")
load(":flatten.bzl", "flatten_test_suite")
load(":sanitize.bzl", "sanitize_test_suite")
load(":concat.bzl", "concat_test_suite")

flatten_test_suite(
    name = "flatten_test",
)

sanitize_test_suite (
   name = "sanitize_test",
)

concat_test_suite(
    name = "concat_test",
)

test_suite(
    name = "starlark",
    tags = [TAG_STARLARK],
)
