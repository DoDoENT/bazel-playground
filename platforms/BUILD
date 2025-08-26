platform(
    name = "arm64-v8a",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:android",
    ],
)

platform(
    name = "armeabi-v7a",
    constraint_values = [
        "@platforms//cpu:armv7",
        "@platforms//os:android",
    ],
)

platform(
    name = "ios-device",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:ios",
    ],
)

platform(
    name = "wasm-basic",
    constraint_values = [
        "@platforms//cpu:wasm32",
        "@platforms//os:emscripten",
    ],
    flags = [
        "--copt=-DBOOST_HAS_PTHREADS", # needed for Boost.Container to build
    ],
)

platform(
    name = "wasm-advanced",
    constraint_values = [
        "@platforms//cpu:wasm32",
        "@platforms//os:emscripten",
    ],
    flags = [
        "--features=simd",
        "--copt=-DBOOST_HAS_PTHREADS", # needed for Boost.Container to build
    ],
)

platform(
    name = "wasm-advanced-threads",
    constraint_values = [
        "@platforms//cpu:wasm32",
        "@platforms//os:emscripten",
    ],
    flags = [
        "--features=simd",
        "--features=use_pthreads",
    ],
)
