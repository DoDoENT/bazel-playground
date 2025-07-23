load("@rules_apple//apple:apple.bzl", "local_provisioning_profile")
load("@rules_apple//apple/testing/default_runner:ios_test_runner.bzl", "ios_test_runner")

load("@rules_xcodeproj//xcodeproj:xcode_provisioning_profile.bzl", "xcode_provisioning_profile")

local_provisioning_profile(
    name = "provisioning_profile",
    profile_name = "iOS Team Provisioning Profile: *",
    team_id = "CQTJWP89J7",
    target_compatible_with = [
        "@platforms//os:ios",
    ],
)

xcode_provisioning_profile(
    name = "xcode_profile",
    managed_by_xcode = True,
    provisioning_profile = ":provisioning_profile",
    visibility = ["//visibility:public"],
    target_compatible_with = [
        "@platforms//os:ios",
    ],
)

ios_test_runner(
    name = "test_runner",
    device_type = "iPhone 16",
    os_version = "18.5",
    visibility = ["//visibility:public"],
)
