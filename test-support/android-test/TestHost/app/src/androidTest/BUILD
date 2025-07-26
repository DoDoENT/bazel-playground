load("@rules_android//android:rules.bzl", "android_binary", "android_library")
load("//test-support/android-test/android_instrumentation_test:android_instrumentation_test.bzl", "android_instrumentation_test")

android_library(
    name = "test-lib",
    srcs = [
        "java/com/example/app/ExampleInstrumentedTest.java",
    ],
    deps = [
        "//test-support/android-test/TestHost/app/src/main:lib",
        "@maven//:junit_junit",
        "@maven//:androidx_test_rules",
        "@maven//:androidx_test_ext_junit",
    ]
)

android_binary(
    name = "test-app",
    manifest = "AndroidTestManifest.xml",
    instruments = "//test-support/android-test/TestHost/app/src/main:app",
    deps = [
        ":test-lib",
    ],
)

# works with 'adb shell am instrument -r -w com.example.app.test/androidx.test.runner.AndroidJUnitRunner'
# obtain log from device with 'adb logcat -s AndroidJUnitRunner'

android_instrumentation_test(
    name = "test",
    test_app = ":test-app",
)
