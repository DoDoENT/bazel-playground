#include "lib/hello-time.h"
#include <ctime>
#include <iostream>

void print_localtime() {
  std::time_t result = std::time(nullptr);
  std::cout << std::asctime(std::localtime(&result));
#ifdef __clang__
  std::cout << "Clang hello!" << std::endl;
#if __has_feature(address_sanitizer)
  std::cout << "AddressSanitizer is enabled!" << std::endl;
#endif
#else
  std::cout << "Another compiler hello!" << std::endl;
#endif // __clang__
}
