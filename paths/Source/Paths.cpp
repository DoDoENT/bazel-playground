
#include <Paths/Paths.hpp>

std::string resolveTestDataPath( std::string_view relativePath )
{
    return "test-data/" + std::string{ relativePath };
}
