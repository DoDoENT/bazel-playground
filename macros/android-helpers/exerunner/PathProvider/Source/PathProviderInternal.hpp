
#include "PathProvider.hpp"

#include <jni.h>

//------------------------------------------------------------------------------
namespace AndroidPaths
{
//------------------------------------------------------------------------------

void initialize( JNIEnv * env, jobject jContext );

void terminate( JNIEnv * env );

int startLogger( char const * app_name );

//------------------------------------------------------------------------------
} // namespace AndroidPaths
//------------------------------------------------------------------------------

