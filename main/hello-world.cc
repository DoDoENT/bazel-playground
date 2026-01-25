#include "lib/hello-time.h"
#include "main/hello-greet.h"
#include <iostream>
#include <string>
#include <thread>

#ifdef __EMSCRIPTEN_PTHREADS__
void threadWork()
{
    std::cout << "Hello from another thread: " << std::this_thread::get_id() << std::endl;
}
#endif

int main(int argc, char** argv) {
  std::string who = "world";
  if (argc > 1) {
    who = argv[1];
  }
  std::cout << get_greet(who) << std::endl;
  print_localtime();
#ifdef __cpp_rtti
    std::cout << "type id of who is" << typeid(who).name() << std::endl;
#endif
#ifdef __EMSCRIPTEN__
  std::cout << "Helloworld compiled with Emscripten!" << std::endl;
#ifdef __wasm_simd128__
  std::cout << "Running in WebAssembly SIMD mode!" << std::endl;
#endif
#ifdef __EMSCRIPTEN_PTHREADS__
  std::cout << "Running in WebAssembly Threads mode!" << std::endl;
  std::thread someThread{ threadWork };
  someThread.join();
#endif
#endif
#ifdef __APPLE__
    std::cout << "Hello world compiled for Apple platform!" << std::endl;
#endif
#ifdef __clang_major__
    std::cout << "Clang version is: " << __clang_major__ << std::endl;
#endif
#ifdef _LIBCPP_VERSION
    std::cout << "libcxx version is: " << _LIBCPP_VERSION << std::endl;
#endif
#ifdef NDEBUG
    std::cout << "Hello world compiled in release mode!" << std::endl;
#else
    std::cout << "Hello world compiled in debug mode!" << std::endl;
#endif
// write whether running on Intel or ARM
#ifdef __aarch64__
    std::cout << "Hello world running on ARM 64-bit!" << std::endl;
#elif __arm__
    std::cout << "Hello world running on ARM 32-bit!" << std::endl;
#elif __i386__
    std::cout << "Hello world running on Intel 32-bit!" << std::endl;
#elif __x86_64__
    #ifdef __AVX2__
        std::cout << "Hello world running on Intel 64-bit (x86-64-v3 with AVX2)!" << std::endl;
    #elif __AVX__
        std::cout << "Hello world running on Intel 64-bit (x86-64-v2 with AVX)!" << std::endl;
    #else
        std::cout << "Hello world running on Intel 64-bit!" << std::endl;
    #endif
#else
    std::cout << "Hello world running on an unknown architecture!" << std::endl;
#endif
  return 0;
}
