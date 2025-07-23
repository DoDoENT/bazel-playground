load("@rules_swift//mixed_language:mixed_language_library.bzl", "mixed_language_library")

mixed_language_library(
    name = "googletest-ios-swift-bridge",
    swift_srcs = [
        "GoogleTestLoader.swift",
        "IosBundlePathProvider.swift",
    ],
    clang_srcs = [
        "GoogleTestInvoker.cpp",
    ],
    hdrs = [
        "GoogleTestInvoker.hpp",
    ],
    module_name = "GoogleTestSwift",
    swift_copts = [
        "-cxx-interoperability-mode=default",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@googletest//:gtest_main",
    ],
    testonly = True,
    tags = ["manual"],
    alwayslink = True,
)
