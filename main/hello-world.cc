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
#ifdef NDEBUG
    std::cout << "Hello world compiled in release mode!" << std::endl;
#else
    std::cout << "Hello world compiled in debug mode!" << std::endl;
#endif
  return 0;
}
