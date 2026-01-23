
# Tags
TAG_HOST = "host"
TAG_IOS = "ios"
TAG_ANDROID = "android"
TAG_WASM_BASIC = "wasm-basic"
TAG_WASM_SIMD = "wasm-simd"
TAG_WASM_SIMD_THREADS = "wasm-simd-threads"
TAG_STARLARK = "starlark"

# Use this tag on tests that require multiple CPU cores to prevent server overcomit
# Implementation note:
# It will reserve 4 CPU cores for that test, thus ensuring at most 2 threadpool-using
# tests to run in parallel on a 8-core machine.
# See https://bazel.build/reference/test-encyclopedia#other-resources for details.
# (2025-09-03, Nenad Mikša)

TAG_MULTI_CPU = "cpu:4"
