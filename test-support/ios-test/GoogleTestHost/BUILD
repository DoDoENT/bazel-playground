load("@rules_cc//cc:objc_library.bzl", "objc_library")
load("@rules_apple//apple:ios.bzl", "ios_application")
load("@rules_apple//apple:versioning.bzl", "apple_bundle_version")
load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "GoogleTestHostSources",
    srcs = [
        "App.swift",
    ],
    tags = ["manual"],
    target_compatible_with = [
        "@platforms//os:ios",
    ],
)

apple_bundle_version(
    name = "GoogleTestHostVersion",
    build_version = "1.0",
    visibility = ["//visibility:public"],
)

ios_application(
    name = "GoogleTestHost",
    visibility = ["//visibility:public"],
    bundle_id = "com.example.GoogleTestHost",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [":Info.plist"],
    minimum_os_version = "15.0",
    provisioning_profile = "//test-support/ios-test:xcode_profile",
    version = ":GoogleTestHostVersion",
    deps = [":GoogleTestHostSources"],  
    tags = ["manual"],
    target_compatible_with = [
        "@platforms//os:ios",
    ],
)
