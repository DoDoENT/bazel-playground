load(":clang_flags.bzl", "clang_flags")

def _calculate_emscripten_flags():
    emscripten_flags = dict(**clang_flags)
    emscripten_flags["compiler_lto"] = [
        "-flto=thin",
    ]
    emscripten_flags["linker_lto"] = [
        "-flto=thin",
    ]
    emscripten_flags["cxx_compiler_exceptions_off"] = emscripten_flags["cxx_compiler_exceptions_off"] + [
        "-s DISABLE_EXCEPTION_CATCHING=1"
    ]

    emscripten_flags["cxx_compiler_exceptions_on"] = emscripten_flags["cxx_compiler_exceptions_on"] + [
        "-s DISABLE_EXCEPTION_CATCHING=0"
    ]
    emscripten_flags["linker_exceptions_off"] = [
        "-s DISABLE_EXCEPTION_CATCHING=1"
    ]
    emscripten_flags["linker_exceptions_on"] = [
        "-s DISABLE_EXCEPTION_CATCHING=0"
    ]
    emscripten_flags["linker_runtime_checks"] = [
        "-s ASSERTIONS=2",
        "-s STACK_OVERFLOW_CHECK=2",
        "-s GL_ASSERTIONS=1",
        "-s SAFE_HEAP=1",
    ]
    emscripten_flags["linker_release_flags"] = [
        "-s ASSERTIONS=0",
        "-s STACK_OVERFLOW_CHECK=0",
        "--closure 1",
        "-s IGNORE_CLOSURE_COMPILER_ERRORS=1",
    ]
    emscripten_flags["linker_common_flags"] = [
        "-s MALLOC=emmalloc",
        "-flto=thin", # needed because bazel can handle only single emscripten cache
        "-Wno-limited-postlink-optimizations",
        # "-s STRICT=1",
        "-s ALLOW_MEMORY_GROWTH=1",
        "--no-heap-copy",
        "-s INITIAL_MEMORY=209715200", # 200MB
        "-s MEMORY_GROWTH_LINEAR_STEP=2097152", # 2MB
        "-s STACK_SIZE=262144", # 256KB
        "-s ALLOW_UNIMPLEMENTED_SYSCALLS=0",
        "-s SUPPORT_ERRNO=0",
        "-s DYNAMIC_EXECUTION=0",
        "-s EXPORTED_FUNCTIONS=['_malloc']",
    ]
    emscripten_flags["compiler_common_flags"] = emscripten_flags["compiler_common_flags"] + [
        "-fno-PIC",
        "-flto=thin", # needed because bazel can handle only single emscripten cache
        # "-s STRICT=1",
        "-mmutable-globals",
        "-mreference-types",
        "-mbulk-memory",
        "-mnontrapping-fptoint",
        "-msign-ext",
    ]

    return emscripten_flags

emscripten_flags = _calculate_emscripten_flags()
