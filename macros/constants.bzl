
# Tags
TAG_HOST = "host"
TAG_IOS = "ios"
TAG_ANDROID = "android"
TAG_WASM_BASIC = "wasm-basic"
TAG_WASM_ADVANCED = "wasm-advanced"
TAG_WASM_ADVANCED_THREADS = "wasm-advanced-threads"
TAG_STARLARK = "starlark"

# Use this tag on tests that require multiple CPU cores to prevent server overcomit
# Implementation note:
# It will reserve 4 CPU cores for that test, thus ensuring at most 2 threadpool-using
# tests to run in parallel on a 8-core machine. Our CI runners are generally configured
# to have 6, 8, or 10 CPU cores, so using 4 is a reasonable choice, given that Bazel
# does not allow us to specify "half of the available cores" or similar.
# See https://bazel.build/reference/test-encyclopedia#other-resources for details.
# (2025-09-03, Nenad Mikša)

TAG_MULTI_CPU = "cpu:4"
