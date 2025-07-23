
#include <TestPaths/TestPaths.hpp>

#if __APPLE__
#include <TargetConditionals.h>
#endif

#if TARGET_OS_IPHONE
// will be defined in the google test ios invoker library
namespace GoogleTest
{
    std::string currentBundlePath();
}
#endif

std::string resolveTestDataPath( std::string_view relativePath )
{
#if TARGET_OS_IPHONE
    auto prefix{ GoogleTest::currentBundlePath() + "/" };
#else
    constexpr auto prefix{ "" };
#endif
    return prefix + std::string{ "test-data/" } + std::string{ relativePath };
}
