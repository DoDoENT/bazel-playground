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
        "-s STRICT=1",
    ]
    emscripten_flags["compiler_common_flags"] = emscripten_flags["compiler_common_flags"] + [
        "-fno-PIC",
        "-s STRICT=1",
    ]

    return emscripten_flags

emscripten_flags = _calculate_emscripten_flags()
