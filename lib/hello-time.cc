#include "lib/hello-time.h"
#include <ctime>
#include <iostream>

void print_localtime() {
  std::time_t result = std::time(nullptr);
  std::cout << std::asctime(std::localtime(&result));
#ifdef __clang__
  std::cout << "Clang hello!" << std::endl;
#else
  std::cout << "Another compiler hello!" << std::endl;
#endif // __clang__
#if __has_feature(address_sanitizer)
  std::cout << "AddressSanitizer is enabled!" << std::endl;
#endif
#if defined(__has_feature)
#  if __has_feature(undefined_behavior_sanitizer)
  std::cout << "Undefined behaviour sanitizer is enabled!" << std::endl;
#  endif
#endif
}
