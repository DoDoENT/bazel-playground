load(":clang_flags.bzl", "clang_flags")

def _calculate_emscripten_flags():
    _local_emscripten_flags = dict(**clang_flags)
    _local_emscripten_flags["compiler_lto"] = [
        "-flto=thin",
    ]
    _local_emscripten_flags["linker_lto"] = [
        "-flto=thin",
    ]
    _local_emscripten_flags["cxx_compiler_exceptions_off"] = _local_emscripten_flags["cxx_compiler_exceptions_off"] + [
        "-s DISABLE_EXCEPTION_CATCHING=1"
    ]

    _local_emscripten_flags["cxx_compiler_exceptions_on"] = _local_emscripten_flags["cxx_compiler_exceptions_on"] + [
        "-s DISABLE_EXCEPTION_CATCHING=0"
    ]
    _local_emscripten_flags["linker_exceptions_off"] = [
        "-s DISABLE_EXCEPTION_CATCHING=1"
    ]
    _local_emscripten_flags["linker_exceptions_on"] = [
        "-s DISABLE_EXCEPTION_CATCHING=0"
    ]
    _local_emscripten_flags["linker_runtime_checks"] = [
        "-s ASSERTIONS=2",
        "-s STACK_OVERFLOW_CHECK=2",
        "-s GL_ASSERTIONS=1",
        "-s SAFE_HEAP=1",
    ]
    _local_emscripten_flags["linker_release_flags"] = [
        "-O3",
        "-s ASSERTIONS=0",
        "-s STACK_OVERFLOW_CHECK=0",
        "--closure 1",
        "-s IGNORE_CLOSURE_COMPILER_ERRORS=1",
    ]
    _local_emscripten_flags["linker_common_flags"] = [
        "-s MALLOC=emmalloc",
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
        "-s EXPORTED_FUNCTIONS=['_malloc','_main']",
    ]
    _local_emscripten_flags["compiler_common_flags"] = _local_emscripten_flags["compiler_common_flags"] + [
        "-fno-PIC",
        # "-s STRICT=1",
        "-mmutable-globals",
        "-mreference-types",
        "-mbulk-memory",
        "-mnontrapping-fptoint",
        "-msign-ext",
    ]

    return _local_emscripten_flags

emscripten_flags = _calculate_emscripten_flags()
