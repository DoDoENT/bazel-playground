#include "ocv-test-helper.hh"


#ifdef __ANDROID__
#include "PathProvider.hpp"
#endif

std::string resolveImagePath( std::string_view filename )
{
#ifdef __ANDROID__
    return AndroidPaths::internalStoragePath() + '/' + resolveTestDataPath( filename );
#else
    return resolveTestDataPath( filename );
#endif
}
