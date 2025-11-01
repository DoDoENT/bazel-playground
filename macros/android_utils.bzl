def sanitize_name(name):
    """Sanitize the test name to ensure it is valid for Android."""
    return name.replace("-", "_").replace(".", "_")

def sanitize_for_jni(sanitized_name):
    """Sanitize name further for purpose of JNI naming"""
    return sanitized_name.replace("_", "_1")

def package_to_path(pkgName):
    """Convert java package name to path"""
    return pkgName.replace(".", "/")

# List od dependencies that need to be added to android_binary or android_library to correctly
# support ASAN/UBSAN sanitizers on Android.
# Note that these need to be added directly to android_binary/android_library as deps, as select is
# performed over host system, so the selection needs to be performed before android_binary/android_library perform the toolchain transition.
SANITIZER_SUPPORT_LIBS = select({
    Label("//macros/android-helpers:macos_asan"): [Label("//macros/android-helpers:android_asan_runtime_darwin")],
    Label("//macros/android-helpers:linux_asan"): [Label("//macros/android-helpers:android_asan_runtime_linux")],
    Label("//macros/android-helpers:windows_asan"): [Label("//macros/android-helpers:android_asan_runtime_windows")],
    Label("//conditions:default"): [],
}) + select({
    Label("//macros/android-helpers:macos_ubsan"): [Label("//macros/android-helpers:android_ubsan_runtime_darwin")],
    Label("//macros/android-helpers:linux_ubsan"): [Label("//macros/android-helpers:android_ubsan_runtime_linux")],
    Label("//macros/android-helpers:windows_ubsan"): [Label("//macros/android-helpers:android_ubsan_runtime_windows")],
    Label("//conditions:default"): [],
}) + select({
    Label("//macros/android-helpers:android-needs-arm64-wrap"): [Label("//macros/android-helpers:android_sanitizer_wrap_arm64-v8a")],
    Label("//macros/android-helpers:android-needs-armv7-wrap"): [Label("//macros/android-helpers:android_sanitizer_wrap_armeabi-v7a")],
    Label("//macros/android-helpers:android-needs-x86-wrap"): [Label("//macros/android-helpers:android_sanitizer_wrap_x86")],
    Label("//macros/android-helpers:android-needs-x86_64-wrap"): [Label("//macros/android-helpers:android_sanitizer_wrap_x86_64")],
    # Note: if multiple android platforms are enabled, don't package the wrap script as we can't match on it in Bazel.
    #       This will manifest just as missing stacktraces for UBSAN reports as the wrap script sets up UBSAN_OPTIONS
    #       environment variable.
    Label("//conditions:default"): [],
})
