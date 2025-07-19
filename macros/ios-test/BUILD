load("@rules_apple//apple/testing/default_runner:ios_xctestrun_runner.bzl", "ios_xctestrun_runner")

ios_xctestrun_runner(
    name = "device-runner",
    xcodebuild_args = [
        "-destination",
        "'platform=iOS,name=dodophone'"
    ]
)
