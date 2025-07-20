load("@rules_apple//apple/testing/default_runner:ios_xctestrun_runner.bzl", "ios_xctestrun_runner")
load("@rules_xcodeproj//xcodeproj:xcode_provisioning_profile.bzl", "xcode_provisioning_profile")

xcode_provisioning_profile(
    name = "xcode_profile",
    managed_by_xcode = True,
    team_id = "CQTJWP89J7",
    provisioning_profile = "bazeltestprofile.mobileprovision",
    visibility = ["//visibility:public"],
)
