load("@rules_android//android:rules.bzl", "android_binary", "android_library")

load("//macros:mobile_library.bzl", "mobile_library" )

mobile_library(
    name = "native-lib",
    srcs = ["cpp/native-lib.cpp"],
    linkstatic = False,
    tags = ["manual"],
)

android_binary(
    name = "app",
    srcs = ["java/com/example/app/MainActivity.java"],
    manifest = "AndroidManifest.xml",
    custom_package = "com.example.app",
    resource_files = glob(["res/**/*"]),
    manifest_values = {"applicationId": "com.example.app"},
    deps = [
        ":native-lib",
    ],
    visibility = ["//visibility:public"],
)
