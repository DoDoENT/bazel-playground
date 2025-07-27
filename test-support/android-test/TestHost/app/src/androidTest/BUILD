load("@rules_android//android:rules.bzl", "android_binary", "android_library")
load("//test-support/android-test/android_instrumentation_test:android_instrumentation_test.bzl", "android_instrumentation_test")

android_binary(
    name = "test-app",
    srcs = [
        "java/com/example/app/ExampleInstrumentedTest.java",
    ],
    manifest = "AndroidTestManifest.xml",
    instruments = "//test-support/android-test/TestHost/app/src/main:app",
    deps = [
        "@maven//:junit_junit",
        "@maven//:androidx_test_rules",
        "@maven//:androidx_test_ext_junit",
    ],
)

# to run the test, use 'bazel test //test-support/android-test/TestHost/app/src/androidTest:test --test_arg=--device_id=<device-id>'
android_instrumentation_test(
    name = "test",
    test_app = ":test-app",
)
