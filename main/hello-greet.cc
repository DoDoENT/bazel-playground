#include "main/hello-greet.h"

#include <string>

#if defined( __linux__ )
#   include <sys/utsname.h>
#endif

std::string get_greet( std::string_view const who )
{
    return "Hello " + std::string{ who };
}

std::string get_greet_with_sysinfo( std::string_view const who)
{
    auto greet{ "Hello " + std::string{ who } };
#if defined( __linux__ ) && !defined( __EMSCRIPTEN__ )
    utsname linuxInfo;
    ::uname( &linuxInfo );
    greet += " (running on Linux kernel: " + std::string( linuxInfo.release ) + " " + linuxInfo.machine + ")";
#endif

    return greet;
}
