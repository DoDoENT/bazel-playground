#include <string>

#include <android/asset_manager.h>
#include <jni.h>

//------------------------------------------------------------------------------
namespace AndroidPaths
{
//------------------------------------------------------------------------------

AAssetManager * currentAssetManager();

std::string const & internalStoragePath();

//------------------------------------------------------------------------------
} // namespace AndroidPaths
//------------------------------------------------------------------------------

