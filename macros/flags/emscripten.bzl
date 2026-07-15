load(":clang_flags.bzl", "clang_flags")

def _calculate_emscripten_flags():
    _local_emscripten_flags = dict(**clang_flags)
    _local_emscripten_flags["compiler_lto"] = [
        "-flto=thin",
    ]
    _local_emscripten_flags["linker_lto"] = [
        "-flto=thin",
        "-Wl,--thinlto-jobs=4",
    ]
    _local_emscripten_flags["cxx_compiler_exceptions_off"] = _local_emscripten_flags["cxx_compiler_exceptions_off"] + [
        "-sDISABLE_EXCEPTION_CATCHING=1"
    ]

    _local_emscripten_flags["cxx_compiler_exceptions_on"] = _local_emscripten_flags["cxx_compiler_exceptions_on"] + [
        "-sDISABLE_EXCEPTION_CATCHING=0"
    ]
    _local_emscripten_flags["linker_exceptions_off"] = [
        "-sDISABLE_EXCEPTION_CATCHING=1"
    ]
    _local_emscripten_flags["linker_exceptions_on"] = [
        "-sDISABLE_EXCEPTION_CATCHING=0"
    ]
    _local_emscripten_flags["linker_runtime_checks"] = [
        "-sASSERTIONS=2",
        "-sSTACK_OVERFLOW_CHECK=2",
        "-sGL_ASSERTIONS=1",
        "-sSAFE_HEAP=1",
    ]
    _local_emscripten_flags["linker_release_flags"] = [
        "-O3",
        "-sASSERTIONS=0",
        "-sSTACK_OVERFLOW_CHECK=0",
        "--closure 1",
        "-sIGNORE_CLOSURE_COMPILER_ERRORS=1",
    ]
    _local_emscripten_flags["linker_common_flags"] = [
        "-sMALLOC=emmalloc",
        "-Wno-limited-postlink-optimizations",
        # "-s STRICT=1",
        "-s ALLOW_MEMORY_GROWTH=1",
        "-sGROWABLE_ARRAYBUFFERS=0",  # not compatible with file packager yet
        "-Wno-pthreads-mem-growth",
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
