#include "lib/hello-time.h"
#include <ctime>
#include <iostream>

std::string get_local_time_as_string()
{
    std::time_t result = std::time(nullptr);

    std::string full_string;
    full_string += std::asctime(std::localtime(&result));
    full_string += '\n';
#ifdef __clang__
    full_string += "Clang hello!\n";
#else
    full_string += "Another compiler hello!\n";
#endif
#if __has_feature(address_sanitizer)
    full_string += "AddressSanitizer is enabled!\n";
#endif
#if __has_feature(undefined_behavior_sanitizer)
    full_string += "Undefined behaviour sanitizer is enabled!\n";
#endif

    return full_string;
}

void print_localtime()
{
    std::cout << get_local_time_as_string();
}
