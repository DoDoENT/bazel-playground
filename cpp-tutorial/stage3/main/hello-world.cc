#include "lib/hello-time.h"
#include "main/hello-greet.h"
#include <iostream>
#include <string>

int main(int argc, char** argv) {
  std::string who = "world";
  if (argc > 1) {
    who = argv[1];
  }
  std::cout << get_greet(who) << std::endl;
  print_localtime();
#ifdef __EMSCRIPTEN__
  std::cout << "Helloworld compiled with Emscripten!" << std::endl;
#ifdef __wasm_simd128__
  std::cout << "Running in WebAssembly SIMD mode!" << std::endl;
#endif
#ifdef __EMSCRIPTEN_PTHREADS__
  std::cout << "Running in WebAssembly Threads mode!" << std::endl;
#endif
#endif
#ifdef __APPLE__
    std::cout << "Hello world compiled for Apple platform! Clang version is: " << __clang_major__ << std::endl;
#endif
  return 0;
}
