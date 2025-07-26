load("@rules_android//android:rules.bzl", "android_binary", "android_library")

load("//macros:mobile_library.bzl", "mobile_library" )

mobile_library(
    name = "native-lib",
    srcs = ["cpp/native-lib.cpp"],
    linkstatic = False,
    tags = ["manual"],
)

android_library(
    name = "lib",
    srcs = ["java/com/example/app/MainActivity.java"],
    custom_package = "com.example.app",
    manifest = "AndroidManifest.xml",
    resource_files = glob(["res/**/*"]),
    deps = [
        ":native-lib",
        # "@maven//:androidx-core-ktx",
        # "@maven//:androidx-appcompat",
        # "@maven//:material",
        # "@maven//:androidx-constraintlayout",
    ],
    visibility = ["//visibility:public"],
)

android_binary(
    name = "app",
    manifest = "AndroidManifest.xml",
    manifest_values = {"applicationId": "com.example.app"},
    deps = [
        ":lib",
    ],
    visibility = ["//visibility:public"],
)
