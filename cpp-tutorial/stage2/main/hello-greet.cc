#include "hello-greet.h"
#include <string>

std::string get_greet(const std::string& who) {
#ifdef __clang__
  return "Clang hello "+ who;
#else
  return "Another compiler hello "+ who;
#endif // __clang__
}
